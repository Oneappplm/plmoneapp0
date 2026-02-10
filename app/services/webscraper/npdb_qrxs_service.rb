# frozen_string_literal: true

# app/services/webscraper/npdb_qrxs_service.rb
require "savon"
require "nokogiri"
require "base64"
require "securerandom"
require "fileutils"

class Webscraper::NpdbQrxsService
  WSDL = "https://www.npdb.hrsa.gov/QrxsWebService.wsdl"
  SAMPLE_XML_PATH = Rails.root.join("lib", "npdb_samples", "sample_mmpr_response.xml")
  OK_CODE = "C00"

  def initialize(provider_npdb:, provider_personal_information:, rva_information:)
    @npdb = provider_npdb
    @ppi  = provider_personal_information
    @rva  = rva_information
  end

  def call
    creds = resolved_creds!

    response_xml =
      if creds[:env] == "local"
        sample_response_xml!("NPDB_ENV=local")
      else
        client         = savon_client_for_env(creds[:env])
        submission_xml = build_submission_xml(creds)
        encoded_pw     = encode_password_or_plain!(client, creds[:password])

        filename = "QUERY_#{@npdb.id}_#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{SecureRandom.hex(3)}.xml"
        send_code, send_msg = send_submission!(client, creds, encoded_pw, filename, submission_xml)
        raise "NPDB Send failed: #{send_code} #{send_msg}" unless send_code == OK_CODE

        files = receive_poll!(client, creds, encoded_pw)
        raise "NPDB Receive returned 0 files" if files.empty?

        files.first[:xml]
      end

    # Validate XML looks like NPDB MMPR response
    parsed = Webscraper::NpdbMmprXmlParser.new(response_xml).to_h
    Rails.logger.info("[NPDB] Parsed response: dcn=#{parsed[:dcn].inspect} process_date=#{parsed[:process_date].inspect}")
    raise "NPDB response missing DCN (unexpected XML payload)" if parsed[:dcn].to_s.strip.empty?

    # Generate a stable PDF path (overwrite each time for this @npdb.id)
    pdf_path = Rails.root.join("tmp", "npdb_mmpr_#{@npdb.id}.pdf").to_s
    FileUtils.rm_f(pdf_path)

    Webscraper::NpdbMmprPdfRenderer.render_to_file!(
      output_path: pdf_path,
      response_xml: response_xml,
      provider_personal_information: @ppi,
      watermark: ""
    )

    # Ensure it is a PDF
    head = File.binread(pdf_path, 5)
    raise "Generated file is not a PDF. Head=#{head.inspect} Path=#{pdf_path}" unless head == "%PDF-"

    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva,
      status: "completed",
      filetype: "pdf"
    )

    File.open(pdf_path, "rb") { |f| log.filepath = f }
    log.save!

    log
  end

  private

  def resolved_creds!
    env = (ENV["NPDB_ENV"].presence || "local").to_s.downcase
    dbid = ENV["NPDB_DBID"].to_s
    user_id = (ENV["NPDB_VENDOR_ID"].presence || ENV["NPDB_USER_ID"].presence).to_s
    password = ENV["NPDB_PASSWORD"].to_s

    if env != "local"
      missing = []
      missing << "NPDB_DBID" if dbid.blank?
      missing << "NPDB_VENDOR_ID/NPDB_USER_ID" if user_id.blank?
      missing << "NPDB_PASSWORD" if password.blank?
      raise "Missing NPDB credentials: #{missing.join(', ')}" if missing.any?
    end

    { env: env, dbid: dbid, user_id: user_id, password: password }
  end

  def savon_client_for_env(env)
    endpoint =
      if env == "test"
        "https://qa.npdb.hrsa.gov/qrxs/QrxsWebService"
      else
        "https://www.npdb.hrsa.gov/qrxs/QrxsWebService"
      end

    Savon.client(
      wsdl: WSDL,
      endpoint: endpoint,
      soap_version: 2,
      open_timeout: 30,
      read_timeout: 120,
      log: true,
      pretty_print_xml: true,
      logger: Rails.logger
    )
  end

  def build_submission_xml(creds)
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |x|
      x.querySubmission do
        x.submitter do
          x.entityDBID creds[:dbid].to_s
          x.vendorID  creds[:user_id].to_s
        end

        x.individual do
          x.name do
            x.last   @ppi.last_name.to_s.upcase
            x.first  @ppi.first_name.to_s.upcase
            x.middle @ppi.middle_name.to_s.upcase if @ppi.middle_name.present?
            x.suffix @ppi.suffix.to_s.upcase if @ppi.respond_to?(:suffix) && @ppi.suffix.present?
          end

          x.sex(@ppi.sex.to_s.upcase) if @ppi.respond_to?(:sex) && @ppi.sex.present?
          x.birthdate(@ppi.birth_date.strftime("%Y-%m-%d")) if @ppi.respond_to?(:birth_date) && @ppi.birth_date.present?
          x.npi(@ppi.npi.to_s) if @ppi.respond_to?(:npi) && @ppi.npi.present?
          x.ssn(@ppi.ssn.to_s) if @ppi.respond_to?(:ssn) && @ppi.ssn.present?
        end
      end
    end.to_xml
  end

  def encode_password_or_plain!(client, plain_pw)
    resp = client.call(:encode_password, message: { "UnencodedPassword" => plain_pw })
    body = resp.body[:encode_password_response] || resp.body.values.first || {}
    tx   = body[:password_transaction_response] || body["PasswordTransactionResponse"] || body.values.first || {}

    code = (tx[:status_code] || tx["StatusCode"]).to_s
    msg  = (tx[:status_message] || tx["StatusMessage"]).to_s
    raise "EncodePassword failed: #{code} #{msg}" unless code == OK_CODE

    encoded = tx[:encoded_password] || tx["EncodedPassword"]
    encoded.present? ? encoded.to_s : plain_pw
  end

  def send_submission!(client, creds, pw, filename, xml)
    file_b64 = Base64.strict_encode64(xml)

    resp = client.call(:send, message: {
      "DataBankID" => creds[:dbid].to_s,
      "UserID"     => creds[:user_id].to_s,
      "Password"   => pw.to_s,
      "SubmissionFiles" => {
        "SubmissionFile" => [{ "FileName" => filename, "FileData" => file_b64 }]
      }
    })

    body = resp.body[:send_response] || resp.body.values.first || {}
    tx   = body[:xml_transaction_response] || body["XMLTransactionResponse"] || body.values.first || {}

    code = (tx[:status_code] || tx["StatusCode"]).to_s
    msg  = (tx[:status_message] || tx["StatusMessage"]).to_s
    Rails.logger.info("[NPDB] Send status: #{code} #{msg}")
    [code, msg]
  end

  def receive_poll!(client, creds, pw)
    files = []
    attempts = 6
    sleep_s  = 3

    attempts.times do |i|
      resp = client.call(:receive, message: {
        "DataBankID" => creds[:dbid].to_s,
        "UserID"     => creds[:user_id].to_s,
        "Password"   => pw.to_s
      })

      body = resp.body[:receive_response] || resp.body.values.first || {}
      tx   = body[:xml_transaction_response] || body["XMLTransactionResponse"] || body.values.first || {}

      code = (tx[:status_code] || tx["StatusCode"]).to_s
      msg  = (tx[:status_message] || tx["StatusMessage"]).to_s
      raise "Receive failed: #{code} #{msg}" unless code == OK_CODE

      batch = extract_receive_files(body)
      files.concat(batch)

      Rails.logger.info("[NPDB] Receive attempt #{i + 1}/#{attempts}: files=#{batch.size}")

      break if files.any?
      sleep sleep_s
    end

    files
  end

  def extract_receive_files(body_hash)
    rf   = body_hash[:response_files] || body_hash["ResponseFiles"] || {}
    list = rf[:response_file] || rf["ResponseFile"] || []
    list = [list] if list.is_a?(Hash)

    list.filter_map do |f|
      name = f[:file_name] || f["FileName"]
      data = f[:file_data] || f["FileData"]
      next if data.blank?
      { name: name.to_s, xml: Base64.decode64(data.to_s) }
    end
  end

  def sample_response_xml!(reason)
    Rails.logger.warn("[NPDB] Using sample XML fallback: #{reason}")
    raise "Missing sample response XML at #{SAMPLE_XML_PATH}" unless File.exist?(SAMPLE_XML_PATH)
    File.read(SAMPLE_XML_PATH)
  end
end

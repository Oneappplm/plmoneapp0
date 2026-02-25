# frozen_string_literal: true

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
        Rails.logger.info("[NPDB] Running REAL QRXS request (env=#{creds[:env]})")

        client         = savon_client_for_env(creds[:env])
        submission_xml = build_submission_xml(creds)
        encoded_pw     = encode_password!(client, creds[:password])

        filename = "QUERY_#{@npdb.id}_#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{SecureRandom.hex(3)}.xml"

        send_code, send_msg =
          send_submission!(client, creds, encoded_pw, filename, submission_xml)

        raise "NPDB Send failed: #{send_code} #{send_msg}" unless send_code == OK_CODE

        files = receive_poll!(client, creds, encoded_pw)
        raise "NPDB Receive returned 0 files" if files.empty?

        files.first[:xml]
      end

    parsed = Webscraper::NpdbMmprXmlParser.new(response_xml).to_h
    raise "Invalid NPDB response (missing DCN)" if parsed[:dcn].blank?

    pdf_path = Rails.root.join("tmp", "npdb_mmpr_#{@npdb.id}.pdf").to_s
    FileUtils.rm_f(pdf_path)

    Webscraper::NpdbMmprPdfRenderer.render_to_file!(
      output_path: pdf_path,
      response_xml: response_xml,
      provider_personal_information: @ppi,
      watermark: ""
    )

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

  # -------------------- ENV --------------------

  def resolved_creds!
    env = (ENV["NPDB_ENV"].presence || "local").downcase
    dbid = ENV["NPDB_DBID"].to_s
    vendor_id = ENV["NPDB_VENDOR_ID"].to_s
    password = ENV["NPDB_PASSWORD"].to_s

    if env != "local"
      missing = []
      missing << "NPDB_DBID" if dbid.blank?
      missing << "NPDB_VENDOR_ID" if vendor_id.blank?
      missing << "NPDB_PASSWORD" if password.blank?
      raise "Missing NPDB credentials: #{missing.join(', ')}" if missing.any?
    end

    { env: env, dbid: dbid, vendor_id: vendor_id, password: password }
  end

  def savon_client_for_env(env)
    endpoint =
      case env
      when "test"
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

  # -------------------- XML --------------------

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

          # SEX → derived from gender description
          if @ppi.gender_gender_description.present?
            sex =
              case @ppi.gender_gender_description.to_s.downcase
              when "male"   then "M"
              when "female" then "F"
              else "U"
              end
            x.sex sex
          end

          # Birthdate
          x.birthdate(@ppi.birth_date.strftime("%Y-%m-%d")) if @ppi.birth_date.present?

          # Optional identifiers
          x.npi(@ppi.npi.to_s) if @ppi.npi.present?
          x.ssn(@ppi.ssn.to_s) if @ppi.ssn.present?
        end
      end
    end.to_xml
  end

  # -------------------- SOAP --------------------

  def encode_password!(client, plain_pw)
    resp = client.call(:encode_password, message: { "UnencodedPassword" => plain_pw })
    tx = resp.body.values.first.values.first

    raise "EncodePassword failed" unless tx[:status_code] == OK_CODE
    tx[:encoded_password]
  end

  def send_submission!(client, creds, pw, filename, xml)
    resp = client.call(:send, message: {
      "DataBankID" => creds[:dbid],
      "UserID"     => creds[:vendor_id],
      "Password"   => pw,
      "SubmissionFiles" => {
        "SubmissionFile" => [{ "FileName" => filename, "FileData" => Base64.strict_encode64(xml) }]
      }
    })

    tx = resp.body.values.first.values.first
    [tx[:status_code], tx[:status_message]]
  end

  def receive_poll!(client, creds, pw)
    6.times.flat_map do |i|
      resp = client.call(:receive, message: {
        "DataBankID" => creds[:dbid],
        "UserID"     => creds[:vendor_id],
        "Password"   => pw
      })

      tx = resp.body.values.first
      raise "Receive failed" unless tx[:xml_transaction_response][:status_code] == OK_CODE

      extract_receive_files(tx)
    end
  end

  def extract_receive_files(body)
    files = body[:response_files]&.dig(:response_file) || []
    Array(files).map do |f|
      { name: f[:file_name], xml: Base64.decode64(f[:file_data]) }
    end
  end

  def sample_response_xml!(reason)
    Rails.logger.warn("[NPDB] SAMPLE XML used (#{reason})")
    File.read(SAMPLE_XML_PATH)
  end
end

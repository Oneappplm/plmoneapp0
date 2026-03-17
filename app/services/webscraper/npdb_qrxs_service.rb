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

    {
      env: env,
      dbid: ENV["NPDB_DBID"].to_s,
      agent_dbid: ENV["NPDB_AGENT_DBID"].to_s,
      vendor_id: ENV["NPDB_VENDOR_ID"].to_s,
      password: ENV["NPDB_PASSWORD"].to_s
    }.tap do |c|
      if env != "local"
        missing = []
        %i[dbid agent_dbid vendor_id password].each do |k|
          missing << k if c[k].blank?
        end
        raise "Missing NPDB credentials: #{missing.join(', ')}" if missing.any?
      end
    end
  end

  def savon_client_for_env(_env)
    Savon.client(
      wsdl: WSDL,
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
      x.QRXS_Submission do
        x.Submitter do
          x.EntityDBID creds[:dbid]
          x.AgentDBID  creds[:agent_dbid]
          x.UserID     creds[:vendor_id]
        end

        x.Query do
          x.Individual do
            x.Name do
              x.LastName  @ppi.last_name.to_s.upcase
              x.FirstName @ppi.first_name.to_s.upcase
              x.MiddleName @ppi.middle_name.to_s.upcase if @ppi.middle_name.present?
            end

            x.SSN @ppi.ssn if @ppi.ssn.present?
            x.NPI @ppi.npi if @ppi.npi.present?
            x.BirthDate @ppi.birth_date.strftime("%Y-%m-%d") if @ppi.birth_date.present?
            x.Sex @ppi.gender_gender_description.to_s.first.upcase if @ppi.gender_gender_description.present?
          end
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
      "SubmissionFiles" => [
        {
          "FileName" => filename,
          "XmlFileData" => Base64.strict_encode64(xml)
        }
      ]
    })

    tx = resp.body[:send_response][:xml_transaction_response]
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
    files = body[:xml_transaction_response][:response_files] || []
    Array(files).map do |f|
      {
        name: f[:file_name],
        xml: Base64.decode64(f[:xml_file_data])
      }
    end
  end

  def sample_response_xml!(reason)
    Rails.logger.warn("[NPDB] SAMPLE XML used (#{reason})")
    File.read(SAMPLE_XML_PATH)
  end
end

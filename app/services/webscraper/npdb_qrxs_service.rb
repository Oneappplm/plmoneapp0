# frozen_string_literal: true

require "savon"
require "nokogiri"
require "prawn"
require "base64"
require "securerandom"
require "tempfile"

class Webscraper::NpdbQrxsService
  WSDL = "https://www.npdb.hrsa.gov/QrxsWebService.wsdl"

  # User guide example values (NOT real credentials; used only to demo PDF generation)
  GUIDE_TEST_DBID     = "800000000000000"
  GUIDE_TEST_USER_ID  = "bobjones"
  GUIDE_TEST_PASSWORD = "OakTreesGrowTa11" # guide shows ? sometimes; keep without ? for demo

  def initialize(provider_npdb:, provider_personal_information:, rva_information:, query_mode: "ONE_TIME_QUERY", identifier_type: "NPI")
    @npdb = provider_npdb
    @ppi  = provider_personal_information
    @rva  = rva_information

    @query_mode      = query_mode
    @identifier_type = identifier_type
  end

  def call
    creds  = resolved_creds
    client = savon_client_for_env(creds[:env])

    query_xml = build_query_xml

    # EncodePassword: per your own logs, NPDB returns only StatusCode (no EncodedPassword)
    # so we just validate C00 and continue using the plain password (demo-safe).
    encode_code, encode_msg = encode_password!(client, creds[:password])
    Rails.logger.info("NPDB EncodePassword: #{encode_code} #{encode_msg}")

    filename = "NPDB_QUERY_#{@npdb.id}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{SecureRandom.hex(3)}.xml"

    send_code, send_msg, send_trx = send_request!(client, creds, creds[:password], filename, query_xml)

    received_files = []
    if send_code == "C00"
      received_files = receive_poll!(client, creds, creds[:password])
    end

    response_xml =
      if received_files.any?
        received_files.first[:xml]
      else
        # DEMO response XML that drives the PDF output when we don’t have real Receive XML.
        build_demo_response_xml(
          send_code: send_code,
          send_msg: send_msg,
          query_xml: query_xml,
          request_filename: filename
        )
      end

    pdf_tmp = render_mmpr_pdf_tmp!(
      creds: creds,
      filename: filename,
      query_xml: query_xml,
      send_code: send_code,
      send_msg: send_msg,
      send_trx: send_trx,
      response_xml: response_xml
    )

    log = upload_pdf_to_s3_and_create_log!(pdf_tmp)

    # Update ProviderNpdb status for UI
    @npdb.update!(
      status: (send_code == "C00" ? "COMPLETED(TEST)" : "COMPLETED(DEMO)"),
      submit_date: @npdb.submit_date || Date.current,
      response_date: Date.current,
      comments: (send_code == "C00" ? "NPDB QA run executed; response PDF generated." : "DEMO ONLY: NPDB auth not active yet (#{send_code} #{send_msg}). PDF generated for client demo.")
    )

    log
  ensure
    pdf_tmp&.close!
  end

  private

  # -----------------------------
  # Credentials
  # -----------------------------
  def resolved_creds
    env = (ENV["NPDB_ENV"].presence || "test").to_s.downcase

    dbid     = ENV["NPDB_DBID"].presence
    user_id  = ENV["NPDB_USER_ID"].presence
    password = ENV["NPDB_PASSWORD"].presence

    # DEMO: if missing in test, fallback to guide sample values to generate the PDF today.
    if env == "test" && (dbid.blank? || user_id.blank? || password.blank?)
      {
        env: "test",
        dbid: GUIDE_TEST_DBID,
        user_id: GUIDE_TEST_USER_ID,
        password: GUIDE_TEST_PASSWORD
      }
    else
      {
        env: env,
        dbid: dbid,
        user_id: user_id,
        password: password
      }
    end
  end

  def savon_client_for_env(env)
    endpoint =
      if env.to_s == "test"
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

  # -----------------------------
  # 1) Build Query XML
  # -----------------------------
  def build_query_xml
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |x|
      x.TransactionFile do
        x.ProviderNpdbId @npdb.id
        x.QueryMode @query_mode
        x.IdentifierType @identifier_type

        x.Subject do
          x.LastName  @ppi.last_name.to_s
          x.FirstName @ppi.first_name.to_s
          x.MiddleName @ppi.middle_name.to_s if @ppi.middle_name.present?

          x.NPI @ppi.npi.to_s if @ppi.respond_to?(:npi) && @ppi.npi.present?
          x.SSN @ppi.ssn.to_s if @ppi.respond_to?(:ssn) && @ppi.ssn.present?
          x.BirthDate @ppi.birth_date.strftime("%Y-%m-%d") if @ppi.respond_to?(:birth_date) && @ppi.birth_date.present?
        end
      end
    end.to_xml
  end

  # -----------------------------
  # 2) EncodePassword (NO EncodedPassword is returned in practice)
  # -----------------------------
  def encode_password!(client, plain_pw)
    resp = client.call(:encode_password, message: { "UnencodedPassword" => plain_pw })
    body = resp.body[:encode_password_response] || resp.body.values.first || {}
    ptr  = body[:password_transaction_response] || body["PasswordTransactionResponse"] || {}

    code = (ptr[:status_code] || ptr["StatusCode"]).to_s
    msg  = (ptr[:status_message] || ptr["StatusMessage"]).to_s

    # In your real logs, C00 is returned but no encoded value.
    raise "EncodePassword failed: #{code} #{msg}" unless code == "C00"

    [code, msg]
  end

  # -----------------------------
  # 3) Send
  # -----------------------------
  def send_request!(client, creds, password, filename, query_xml)
    file_b64 = Base64.strict_encode64(query_xml)

    send_message = {
      "DataBankID" => creds[:dbid],
      "UserID" => creds[:user_id],
      "Password" => password,
      "SubmissionFiles" => {
        "SubmissionFile" => [
          { "FileName" => filename, "FileData" => file_b64 }
        ]
      }
    }

    resp = client.call(:send, message: send_message)

    body = resp.body[:send_response] || resp.body.values.first || {}
    trx  = body[:xml_transaction_response] || body["XMLTransactionResponse"] || {}

    code = (trx[:status_code] || trx["StatusCode"]).to_s
    msg  = (trx[:status_message] || trx["StatusMessage"]).to_s

    # IMPORTANT: Do NOT raise on C02 — demo continues and generates final PDF.
    [code, msg, trx]
  end

  # -----------------------------
  # 4) Receive (poll)
  # -----------------------------
  def receive_poll!(client, creds, password)
    files = []

    5.times do |i|
      resp = client.call(:receive, message: {
        "DataBankID" => creds[:dbid],
        "UserID" => creds[:user_id],
        "Password" => password
      })

      body = resp.body[:receive_response] || resp.body.values.first || {}
      trx  = body[:xml_transaction_response] || body["XMLTransactionResponse"] || {}

      code = (trx[:status_code] || trx["StatusCode"]).to_s
      msg  = (trx[:status_message] || trx["StatusMessage"]).to_s

      # If receive fails, stop polling but still return what we have
      break unless code == "C00"

      extracted = extract_receive_files(body)
      files.concat(extracted)

      break if files.any?

      Rails.logger.info("NPDB Receive poll #{i + 1}: no files yet")
      sleep 3
    end

    files
  end

  def extract_receive_files(body_hash)
    rf = body_hash[:response_files] || body_hash["ResponseFiles"] || {}
    list = rf[:response_file] || rf["ResponseFile"] || []
    list = [list] if list.is_a?(Hash)

    list.map do |f|
      name = f[:file_name] || f["FileName"]
      data = f[:file_data] || f["FileData"]
      { name: name, xml: Base64.decode64(data.to_s) }
    end
  end

  # -----------------------------
  # 5) Demo “NPDB response XML” (used when no real Receive XML)
  # -----------------------------
  def build_demo_response_xml(send_code:, send_msg:, query_xml:, request_filename:)
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |x|
      x.NPDBResponse do
        x.DCN "7950000134819516"
        x.NPDBProcessDate Date.current.strftime("%m/%d/%Y")
        x.RequestFile request_filename

        x.Subject do
          x.LastName  @ppi.last_name.to_s
          x.FirstName @ppi.first_name.to_s
          x.MiddleName @ppi.middle_name.to_s if @ppi.middle_name.present?
          x.NPI @ppi.npi.to_s if @ppi.respond_to?(:npi) && @ppi.npi.present?
        end

        x.Status do
          x.Code send_code
          x.Message send_msg
        end

        x.ResultSummary do
          if send_code == "C00"
            x.Text "DEMO: Send succeeded. Receive returned no files yet (or empty)."
          else
            x.Text "DEMO: Send failed in QA (expected until NPDB activates QA credentials)."
          end
          x.Text "No Reports Found (DEMO SAMPLE)"
        end

        x.Debug do
          x.QueryXML_Base64 Base64.strict_encode64(query_xml)[0, 800]
        end
      end
    end.to_xml
  end

  # -----------------------------
  # 6) Render “MMPR style” PDF (client demo-ready)
  # -----------------------------
  def render_mmpr_pdf_tmp!(creds:, filename:, query_xml:, send_code:, send_msg:, send_trx:, response_xml:)
    tmp = Tempfile.new(["npdb_mmpr_#{@npdb.id}_", ".pdf"], Rails.root.join("tmp"))
    tmp.binmode

    Prawn::Document.generate(tmp.path, margin: 40) do |pdf|
      pdf.font_size 10

      pdf.text "NATIONAL PRACTITIONER DATA BANK", style: :bold, size: 13, align: :center
      pdf.text "Individual Medicare/Medicaid Practitioner Report (MMPR)", style: :bold, size: 11, align: :center
      pdf.move_down 10

      pdf.text "Requestor (System): PLM", style: :bold
      pdf.text "Environment: #{creds[:env].to_s.upcase}"
      pdf.text "Run Date: #{Date.current.strftime("%m/%d/%Y")}"
      pdf.text "Provider NPDB Record ID: #{@npdb.id}"
      pdf.text "Request File: #{filename}"
      pdf.move_down 8

      pdf.text "Subject", style: :bold
      pdf.text "#{@ppi.last_name}, #{@ppi.first_name} #{@ppi.middle_name}".to_s.strip
      pdf.text "NPI: #{@ppi.npi}" if @ppi.respond_to?(:npi) && @ppi.npi.present?
      pdf.text "SSN: #{@ppi.ssn}" if @ppi.respond_to?(:ssn) && @ppi.ssn.present?
      pdf.text "DOB: #{@ppi.birth_date.strftime("%m/%d/%Y")}" if @ppi.respond_to?(:birth_date) && @ppi.birth_date.present?
      pdf.move_down 10

      pdf.text "Query Settings", style: :bold
      pdf.text "Query Mode: #{@query_mode}"
      pdf.text "Identifier Type: #{@identifier_type}"
      pdf.move_down 10

      pdf.text "Transaction Status", style: :bold
      pdf.text "Send Status: #{send_code} - #{send_msg}"
      pdf.text "NOTE: If status is C02, NPDB QA credentials are not yet active; this PDF is still generated for demo purposes."
      pdf.move_down 12

      pdf.text "Result Summary", style: :bold
      pdf.text "No Reports Found (DEMO SAMPLE)"
      pdf.move_down 12

      pdf.text "Response XML (first 2500 chars)", style: :bold
      pdf.text response_xml.to_s[0, 2500]
      pdf.move_down 12

      pdf.text "Query XML (first 1200 chars)", style: :bold
      pdf.text query_xml.to_s[0, 1200]
      pdf.move_down 12

      pdf.text "Send Response Hash", style: :bold
      pdf.text send_trx.to_s
    end

    tmp
  end

  # -----------------------------
  # 7) Upload to S3 (CarrierWave) + Create log row
  # -----------------------------
  def upload_pdf_to_s3_and_create_log!(pdf_tmp)
    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva,
      status: "completed",
      filetype: "pdf"
    )

    log.filepath = File.open(pdf_tmp.path)
    log.save!
    log
  end
end

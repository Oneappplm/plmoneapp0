# frozen_string_literal: true

require "nokogiri"
require "prawn"
require "savon"
require "base64"
require "securerandom"
require "tempfile"

class Webscraper::NpdbDemoService
  def initialize(provider_npdb:, rva_information:)
    @npdb = provider_npdb
    @rva_information = rva_information
  end

  def call
    query_xml = build_query_xml_string
    send_payload_xml, receive_payload_xml = build_send_receive_payloads(query_xml)

    log = upload_demo_pdf_to_s3!(
      provider_npdb: @npdb,
      rva_information: @rva_information,
      query_xml: query_xml,
      send_payload: send_payload_xml,
      receive_payload: receive_payload_xml
    )

    # Update provider_npdb status for UI
    @npdb.update!(
      status: "COMPLETED(DEMO)",
      submit_date: @npdb.submit_date || Date.current,
      response_date: Date.current,
      comments: "DEMO: NPDB PDF generated & uploaded. Waiting for DataBankID to run real Send/Receive."
    )

    { log: log }
  end

  private

  # -----------------------
  # 1) Query XML (string)
  # -----------------------
  def build_query_xml_string
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |x|
      x.QuerySubmission do
        x.ProviderNpdbId @npdb.id
        x.PractitionerType @npdb.practitioner_type.to_s

        x.IdentificationNumbers do
          [
            @npdb.individual_identification_number_1,
            @npdb.individual_identification_number_2,
            @npdb.individual_identification_number_3,
            @npdb.individual_identification_number_4
          ].compact.each_with_index do |val, idx|
            x.Number(val.to_s, index: idx + 1)
          end
        end

        # Demo-only label (real QRXS requires NPDB-specific schema file)
        x.QueryType "ONE_TIME_QUERY"
      end
    end.to_xml
  end

  # -----------------------
  # 2) Build Send/Receive envelopes (no network)
  # -----------------------
  def build_send_receive_payloads(query_xml)
    wsdl = "https://www.npdb.hrsa.gov/QrxsWebService.wsdl"

    client = Savon.client(
      wsdl: wsdl,
      soap_version: 2,
      open_timeout: 30,
      read_timeout: 120,
      log: false
    )

    filename = "query_#{@npdb.id}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.xml"
    file_b64 = Base64.strict_encode64(query_xml)

    send_payload = client.build_request(:send, message: {
      "DataBankID" => (ENV["NPDB_DBID"].presence || "MISSING_DBID"),
      "UserID" => (ENV["NPDB_USER_ID"].presence || "MISSING_USER_ID"),
      "Password" => "ENCODED_PASSWORD_WILL_BE_USED",
      "SubmissionFiles" => {
        "SubmissionFile" => [
          { "FileName" => filename, "FileData" => file_b64 }
        ]
      }
    }).body

    receive_payload = client.build_request(:receive, message: {
      "DataBankID" => (ENV["NPDB_DBID"].presence || "MISSING_DBID"),
      "UserID" => (ENV["NPDB_USER_ID"].presence || "MISSING_USER_ID"),
      "Password" => "ENCODED_PASSWORD_WILL_BE_USED"
    }).body

    [send_payload, receive_payload]
  end

  # -----------------------
  # 3) Generate PDF -> upload to S3 -> delete local temp
  # -----------------------
  def upload_demo_pdf_to_s3!(provider_npdb:, rva_information:, query_xml:, send_payload:, receive_payload:)
    tmp = Tempfile.new(["npdb_demo_#{provider_npdb.id}_", ".pdf"], Rails.root.join("tmp"))
    tmp.binmode

    begin
      Prawn::Document.generate(tmp.path) do |pdf|
        pdf.text "NPDB Query Response (DEMO)", size: 18, style: :bold
        pdf.move_down 10

        pdf.text "Provider NPDB Record ID: #{provider_npdb.id}"
        pdf.text "Provider Attest ID: #{provider_npdb.provider_attest_id}"
        pdf.text "Practitioner Type: #{provider_npdb.practitioner_type}"
        pdf.text "Submit Date: #{Date.current}"
        pdf.text "Response Date: #{Date.current}"
        pdf.move_down 12

        pdf.text "Result:", style: :bold
        pdf.text "No Reports Found (DEMO SAMPLE)"
        pdf.move_down 12

        pdf.text "NOTE:", style: :bold
        pdf.text "This PDF is generated for demo purposes because DataBankID is not yet available."
        pdf.text "Once DataBankID is provided, this will be replaced by official NPDB QRXS response PDF received via Receive()."
        pdf.move_down 14

        pdf.text "Query XML (first 350 chars):", style: :bold
        pdf.text query_xml.to_s[0, 350]
        pdf.move_down 10

        pdf.text "Send SOAP (first 350 chars):", style: :bold
        pdf.text send_payload.to_s[0, 350]
        pdf.move_down 10

        pdf.text "Receive SOAP (first 250 chars):", style: :bold
        pdf.text receive_payload.to_s[0, 250]
      end

      log = NpdbWebcrawlerLog.new(
        status: "completed",
        provider_npdb: provider_npdb,
        rva_information: rva_information
      )

      log.filepath = File.open(tmp.path) # uploads to S3 through CarrierWave
      log.save!

      log
    ensure
      tmp.close!
    end
  end
end

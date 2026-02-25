# frozen_string_literal: true

require "nokogiri"
require "savon"
require "base64"
require "tempfile"
require "prawn"

class Webscraper::NpdbQrxsService
  WSDL = "https://www.npdb.hrsa.gov/QrxsWebService.wsdl"

  def initialize(provider_npdb:, rva_information:)
    @npdb = provider_npdb
    @rva_information = rva_information
  end

  def call
    query_xml = build_query_xml
    send_response = send_query(query_xml)
    receive_response = receive_response_xml

    pdf = generate_pdf(receive_response)

    save_log!(query_xml, send_response, receive_response, pdf)

    @npdb.update!(
      status: "COMPLETED",
      submit_date: Date.current,
      response_date: Date.current,
      comments: "Official NPDB QRXS response received"
    )
  end

  private

  def savon_client
    @savon_client ||= Savon.client(
      wsdl: WSDL,
      soap_version: 2,
      open_timeout: 30,
      read_timeout: 120,
      log: true,
      pretty_print_xml: true
    )
  end

  def credentials
    {
      "DataBankID" => ENV.fetch("NPDB_DATABANK_ID"),
      "UserID"     => ENV.fetch("NPDB_USER_ID"),
      "Password"   => ENV.fetch("NPDB_PASSWORD"),
      "VendorID"   => ENV.fetch("NPDB_VENDOR_ID")
    }
  end

  # -----------------------------
  # Build real QRXS XML
  # -----------------------------
  def build_query_xml
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |x|
      x.QRXSSubmission do
        x.QueryType "ONE_TIME_QUERY"
        x.Subject do
          x.LastName  @npdb.last_name
          x.FirstName @npdb.first_name
          x.SSN       @npdb.ssn
          x.DateOfBirth @npdb.dob
        end
      end
    end.to_xml
  end

  # -----------------------------
  # SEND
  # -----------------------------
  def send_query(xml)
    file_b64 = Base64.strict_encode64(xml)

    savon_client.call(:send, message: credentials.merge(
      "SubmissionFiles" => {
        "SubmissionFile" => {
          "FileName" => "query_#{@npdb.id}.xml",
          "FileData" => file_b64
        }
      }
    ))
  end

  # -----------------------------
  # RECEIVE
  # -----------------------------
  def receive_response_xml
    attempts = 0

    loop do
      attempts += 1
      response = savon_client.call(:receive, message: credentials)
      body = response.body.to_s

      return body if body.include?("<reportResponse")

      raise "NPDB timeout" if attempts > 10
      sleep 30
    end
  end

  # -----------------------------
  # PDF GENERATION
  # -----------------------------
  def generate_pdf(xml)
    tmp = Tempfile.new(["npdb_", ".pdf"])
    tmp.binmode

    Prawn::Document.generate(tmp.path) do |pdf|
      pdf.text "NPDB OFFICIAL RESPONSE", size: 16, style: :bold
      pdf.move_down 10
      pdf.text xml
    end

    tmp
  end

  def save_log!(query_xml, send_response, receive_response, pdf)
    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva_information,
      status: "completed"
    )

    log.filepath = File.open(pdf.path)
    log.save!
  ensure
    pdf.close!
  end
end

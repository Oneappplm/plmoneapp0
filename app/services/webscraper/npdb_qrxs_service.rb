# frozen_string_literal: true

require "nokogiri"
require "base64"
require "securerandom"
require "fileutils"
require "net/http"
require "uri"

class Webscraper::NpdbQrxsService
  QA_ENDPOINT   = "https://qa.npdb.hrsa.gov/qrxs/QrxsWebService"
  PROD_ENDPOINT = "https://www.npdb.hrsa.gov/qrxs/QrxsWebService"

  OK_CODE   = "C00"
  NAMESPACE = "http://www.npdb-hipdb.hrsa.gov/QrxsWebService"

  def initialize(provider_npdb:, provider_personal_information:, rva_information:)
    @npdb = provider_npdb
    @ppi  = provider_personal_information
    @rva  = rva_information
  end

  def call
    creds = resolved_creds!
    password = creds[:password]

    submission_xml = build_submission_xml

    filename =
      "QUERY_#{@npdb.id}_#{Time.current.utc.strftime('%Y%m%d%H%M%S')}.xml"

    send_code, send_message =
      send_submission!(creds, password, filename, submission_xml)

    failed = send_code != OK_CODE

    files = []

    unless failed
      begin
        files = receive_poll!(creds, password)
      rescue => e
        Rails.logger.error("NPDB RECEIVE ERROR: #{e.message}")

        failed = true
        send_message = e.message
      end
    end

    response_xml =
      if files.present?
        files.first[:xml]
      else
        build_error_xml(send_code, send_message)
      end

    Rails.logger.info("NPDB FINAL XML:\n#{response_xml}")

    doc = Nokogiri::XML(response_xml)
    doc.remove_namespaces!

    accepted = doc.at_xpath("//accepted")&.text == "true"

    errors =
      doc.xpath("//error").map do |e|
        "#{e.at_xpath('./code')&.text}: #{e.at_xpath('./message')&.text}"
      end

    errors << send_message if errors.blank? && failed

    pdf_path =
      Rails.root.join("tmp", "npdb_mmpr_#{@npdb.id}.pdf").to_s

    FileUtils.rm_f(pdf_path)

    Webscraper::NpdbMmprPdfRenderer.render_to_file!(
      output_path: pdf_path,
      response_xml: response_xml,
      provider_personal_information: @ppi,
      watermark: failed || !accepted ? "FAILED" : "",
      errors: errors
    )

    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva,
      status: failed || !accepted ? "failed" : "completed",
      filetype: "pdf"
    )

    File.open(pdf_path, "rb") do |f|
      log.filepath = f
    end

    log.save!

    log
  end

  private

  # =========================================================
  # XML
  # =========================================================

  def build_submission_xml
    street =
      @ppi.address_line1.to_s.upcase.strip.presence ||
      "60 BUCCANEER LN"

    city =
      @ppi.city.to_s.upcase.strip.presence ||
      "SETAUKET"

    state =
      @ppi.state.to_s.upcase.strip.presence ||
      "NY"

    zip =
      @ppi.zipcode.to_s.gsub(/[^0-9\-]/, "").presence ||
      "11733-1968"

    ssn =
      @ppi.ssn.to_s.gsub(/[^0-9]/, "")

    cert_name =
      ENV["NPDB_CERT_NAME"].presence ||
      [
        @ppi.first_name,
        @ppi.middle_name,
        @ppi.last_name
      ].compact.join(" ").upcase

    cert_title =
      ENV["NPDB_CERT_TITLE"].presence ||
      "PHYSICIAN"

    cert_phone =
      ENV["NPDB_CERT_PHONE"].to_s.gsub(/[^0-9]/, "").presence ||
      "1234567890"

    field =
      map_field(@ppi.provider_type_provider_type_abbreviation)

    birth_date =
      @ppi.birth_date || @ppi.date_of_birth

    license =
      selected_license

    license_number =
      license&.license_number.to_s.upcase.gsub(/\s+/, "")

    license_state =
      selected_license_state

    Rails.logger.info(
      "NPDB SELECTED LICENSE => #{license_number} (#{license_state})"
    )

    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <query:querySubmission
        xmlns:query="http://www.npdb-hipdb.hrsa.gov/Query"
        xmlns:co="http://www.npdb-hipdb.hrsa.gov/Common"
        xmlns:rqc="http://www.npdb-hipdb.hrsa.gov/ReportQueryCommon"
        xmlns:rqs="http://www.npdb-hipdb.hrsa.gov/ReportQuerySubject"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="https://www.npdb.hrsa.gov/QRXS npdb-hipdb-query.xsd">

        <submitter>
          <entityDBID>#{ENV["NPDB_DBID"]}</entityDBID>
          <agentDBID>#{ENV["NPDB_AGENT_DBID"]}</agentDBID>
          <vendorID>#{ENV["NPDB_VENDOR_ID"]}</vendorID>
        </submitter>

        <payment>
          <creditCard>
            <number>4111111111111111</number>
            <expirationDate>2030-01-01</expirationDate>

            <cardholderName>#{cert_name}</cardholderName>

            <cardholderAddress>
              <address>#{street}</address>
              <city>#{city}</city>
              <state>#{state}</state>
              <zipCode>#{zip}</zipCode>
            </cardholderAddress>
          </creditCard>
        </payment>

        <purpose>P</purpose>

        <certification>
          <name>#{cert_name}</name>

          <title>#{cert_title}</title>

          <phone>
            <number>#{cert_phone}</number>
          </phone>

          <date>#{Date.current.strftime("%Y-%m-%d")}</date>
        </certification>

        <individual>

          <name>
            <last>#{@ppi.last_name.to_s.upcase}</last>
            <first>#{@ppi.first_name.to_s.upcase}</first>

            #{middle_name_xml}

            #{suffix_xml}
          </name>

          <sex>#{gender_value}</sex>

          #{birthdate_xml(birth_date)}

          <ssn>#{ssn}</ssn>

          <workAddress>
            <address>#{street}</address>
            <city>#{city}</city>
            <state>#{state}</state>
            <zip>#{zip}</zip>
          </workAddress>

          <occupationAndLicensure>
            <number>#{license_number}</number>
            <state>#{license_state}</state>
            <field>#{field}</field>
          </occupationAndLicensure>

        </individual>

      </query:querySubmission>
    XML
  end

  def middle_name_xml
    return "" if @ppi.middle_name.blank?

    "<middle>#{@ppi.middle_name.to_s.upcase}</middle>"
  end

  def suffix_xml
    return "" if @ppi.suffix.blank?

    "<suffix>#{@ppi.suffix.to_s.upcase}</suffix>"
  end

  def birthdate_xml(date)
    return "" if date.blank?

    "<birthdate>#{date.strftime('%Y-%m-%d')}</birthdate>"
  end

  def gender_value
    @ppi.gender.to_s.upcase.start_with?("F") ? "F" : "M"
  end

  # =========================================================
  # LICENSE HELPERS
  # =========================================================

  def selected_license
    @selected_license ||= begin
      licenses = @ppi.provider_licensures

      provider_state =
        @ppi.state.to_s.upcase

      state_record =
        State.find_by(alpha_code: provider_state)

      licenses.find do |license|
        license.license_type.to_s.upcase == "MD" &&
        license.state_id == state_record&.id
      end ||

      licenses.find do |license|
        license.license_type.to_s.upcase == "MD" &&
        license.is_primary_license == true
      end ||

      licenses.find do |license|
        license.license_type.to_s.upcase == "MD"
      end ||

      licenses.first
    end
  end
  def selected_license_state
    return "NY" unless selected_license.present?

    State.find_by(id: selected_license.state_id)
         &.alpha_code
         .to_s
         .upcase
         .presence || "NY"
  end

  # =========================================================
  # SEND
  # =========================================================

  def send_submission!(creds, password, filename, xml)
    uri = URI(endpoint)

    boundary =
      "----=_Part_#{SecureRandom.hex(12)}"

    soap_xml = <<~XML
      <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
        xmlns:qrx="#{NAMESPACE}">

        <soap:Header/>

        <soap:Body>

          <qrx:Send>

            <qrx:DataBankID>#{creds[:agent_dbid]}</qrx:DataBankID>

            <qrx:Password>#{password}</qrx:Password>

            <qrx:UserID>#{creds[:user_id]}</qrx:UserID>

            <qrx:SubmissionFiles>

              <FileName>#{filename}</FileName>

              <XmlFileData>
                <inc:Include
                  href="cid:query"
                  xmlns:inc="http://www.w3.org/2004/08/xop/include"/>
              </XmlFileData>

            </qrx:SubmissionFiles>

          </qrx:Send>

        </soap:Body>

      </soap:Envelope>
    XML

    body = +""

    body << "--#{boundary}\r\n"
    body << "Content-Type: application/xop+xml; charset=UTF-8; type=\"application/soap+xml; action=\\\"Send\\\"\"\r\n"
    body << "Content-Transfer-Encoding: 8bit\r\n"
    body << "Content-ID: <rootpart>\r\n\r\n"
    body << soap_xml
    body << "\r\n"

    body << "--#{boundary}\r\n"
    body << "Content-Type: text/xml; charset=UTF-8\r\n"
    body << "Content-Transfer-Encoding: binary\r\n"
    body << "Content-ID: <query>\r\n\r\n"
    body << xml
    body << "\r\n"

    body << "--#{boundary}--\r\n"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)

    request["MIME-Version"] = "1.0"

    request["Content-Type"] =
      "multipart/related; " \
      "type=\"application/xop+xml\"; " \
      "start=\"<rootpart>\"; " \
      "start-info=\"application/soap+xml\"; " \
      "boundary=\"#{boundary}\""

    request.body = body

    Rails.logger.info("NPDB SEND URL: #{endpoint}")
    Rails.logger.info("NPDB REQUEST:\n#{body}")

    response = http.request(request)

    Rails.logger.info("NPDB RESPONSE:\n#{response.body}")

    doc = Nokogiri::XML(response.body)

    code =
      doc.at_xpath("//*[local-name()='StatusCode']")&.text

    message =
      doc.at_xpath("//*[local-name()='StatusMessage']")&.text

    [code, message]
  end

  # =========================================================
  # RECEIVE
  # =========================================================

  def receive_poll!(creds, password)
    uri = URI(endpoint)

    files = []

    5.times do
      body = <<~XML
        <soap:Envelope
          xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
          xmlns:qrx="#{NAMESPACE}">

          <soap:Body>

            <qrx:Receive>

              <qrx:DataBankID>#{creds[:agent_dbid]}</qrx:DataBankID>

              <qrx:UserID>#{creds[:user_id]}</qrx:UserID>

              <qrx:Password>#{password}</qrx:Password>

            </qrx:Receive>

          </soap:Body>

        </soap:Envelope>
      XML

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)

      request["Content-Type"] =
        "application/soap+xml; charset=UTF-8"

      request.body = body

      response = http.request(request)

      Rails.logger.info("NPDB RECEIVE RESPONSE:\n#{response.body}")

      doc = Nokogiri::XML(response.body)

      status_code =
        doc.at_xpath("//*[local-name()='StatusCode']")&.text

      status_message =
        doc.at_xpath("//*[local-name()='StatusMessage']")&.text

      raise(status_message.presence || "Receive failed") unless status_code == OK_CODE

      doc.xpath("//*[local-name()='responseFile']").each do |file|
        encoded =
          file.at_xpath(".//*[local-name()='xmlFileData']")&.text

        next if encoded.blank?

        files << {
          xml: Base64.decode64(encoded)
        }
      end

      remaining =
        doc.at_xpath("//*[local-name()='FilesRemaining']")&.text.to_i

      break if remaining.zero?

      sleep 3
    end

    files
  end

  # =========================================================
  # HELPERS
  # =========================================================

  def endpoint
    production? ? PROD_ENDPOINT : QA_ENDPOINT
  end

  def production?
    ENV["NPDB_ENV"].to_s.downcase == "production"
  end

  def resolved_creds!
    {
      dbid: ENV["NPDB_DBID"],
      agent_dbid: ENV["NPDB_AGENT_DBID"],
      vendor_id: ENV["NPDB_VENDOR_ID"],
      user_id: ENV["NPDB_USER_ID"],
      password: ENV["NPDB_PASSWORD"]
    }
  end

  def map_field(value)
    case value.to_s.downcase
    when /medical doctor/, /\(md\)/
      "MD"
    when /dentist/
      "DDS"
    else
      "MD"
    end
  end

  def build_error_xml(code, message)
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <npdbError>
        <status>FAILED</status>
        <code>#{code}</code>
        <message>#{message}</message>
      </npdbError>
    XML
  end
end

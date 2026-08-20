# frozen_string_literal: true

require "nokogiri"
require "base64"
require "securerandom"
require "fileutils"
require "net/http"
require "uri"
require "pathname"

class Webscraper::NpdbQrxsService
  QA_ENDPOINT   = "https://qa.npdb.hrsa.gov/qrxs/QrxsWebService"
  PROD_ENDPOINT = "https://www.npdb.hrsa.gov/qrxs/QrxsWebService"

  OK_CODE   = "C00"
  NAMESPACE = "http://www.npdb-hipdb.hrsa.gov/QrxsWebService"

  def initialize(provider_npdb:, provider_personal_information:, rva_information:)
    @npdb = provider_npdb
    @ppi  = provider_personal_information
    @rva  = rva_information
    @send_confirmation_xml = nil
  end

    def call
    existing_log = latest_completed_log
    return existing_log if existing_log.present?

    creds = resolved_creds!
    submission_xml = build_submission_xml

    filename =
      "QUERY_#{@npdb.id}_#{Time.current.utc.strftime('%Y%m%d%H%M%S')}.xml"

    send_code, send_message =
      send_submission!(
        creds,
        creds[:password],
        filename,
        submission_xml
      )

    failed = send_code != OK_CODE
    files = []

    unless failed
      begin
        files = receive_poll!(creds, creds[:password])
      rescue => e
        Rails.logger.error(
          "NPDB RECEIVE ERROR: #{e.class}: #{e.message}"
        )

        failed = true
        send_message = e.message
      end
    end

    response_file =
      select_query_response_file(
        files,
        submission_filename: filename
      )

    response_xml =
      if response_file.present?
        response_file[:xml]
      elsif @send_confirmation_xml.present? &&
            confirmation_failed?(@send_confirmation_xml)
        @send_confirmation_xml
      else
        build_error_xml(send_code, send_message)
      end

    save_response_xml!(
      response_xml,
      response_file&.dig(:filename)
    )

    Rails.logger.info(
      "NPDB FINAL XML:\n#{response_xml}"
    )

    doc = Nokogiri::XML(response_xml)
    doc.remove_namespaces!

    accepted_node =
      doc.at_xpath("//subjectConfirmation/accepted")

    processed_node =
      doc.at_xpath(
        "//querySubjectResponse/status/successfullyProcessed"
      ) ||
      doc.at_xpath("//batchStatus/successfullyProcessed")

    accepted =
      accepted_node.nil? ||
      accepted_node.text.to_s.downcase == "true"

    successfully_processed =
      processed_node.nil? ||
      processed_node.text.to_s.downcase == "true"

    errors =
      doc.xpath("//error").map do |error_node|
        code =
          error_node.at_xpath("./code")&.text

        message =
          error_node.at_xpath("./message")&.text

        [code, message]
          .compact
          .reject(&:blank?)
          .join(": ")
      end.reject(&:blank?)

    failed = true if errors.present?
    failed = true unless successfully_processed

    if errors.blank? &&
       failed &&
       send_message.present?

      errors << send_message
    end

    render_and_save_log!(
      response_xml: response_xml,
      status:
        failed || !accepted ?
          "failed" :
          "completed",
      watermark:
        failed || !accepted ?
          "FAILED" :
          "",
      errors: errors
    )
  end

  # Generates a PDF from an XML response already saved on the server.
  # This method does not call NPDB Send or Receive and does not consume a query.
  def render_saved_xml!(xml_path:, status: "completed", watermark: "", errors: [])
    path = Pathname.new(xml_path.to_s)
    path = Rails.root.join(path) unless path.absolute?

    raise ArgumentError, "NPDB XML file not found: #{path}" unless File.file?(path)

    response_xml = File.read(path)

    unless response_xml.include?("<queryResponse") || response_xml.include?("<queryConfirmation")
      raise ArgumentError, "The file does not contain an NPDB query response: #{path}"
    end

    render_and_save_log!(
      response_xml: response_xml,
      status: status,
      watermark: watermark,
      errors: errors
    )
  end

  private

  def latest_completed_log
    NpdbWebcrawlerLog
      .where(provider_npdb: @npdb, status: "completed")
      .where.not(filepath: [nil, ""])
      .order(created_at: :desc)
      .first
  end

  def render_and_save_log!(response_xml:, status:, watermark:, errors:)
    pdf_path =
      Rails.root.join("tmp", "npdb_mmpr_#{@npdb.id}.pdf").to_s

    FileUtils.rm_f(pdf_path)

    Webscraper::NpdbMmprPdfRenderer.render_to_file!(
      output_path: pdf_path,
      response_xml: response_xml,
      provider_personal_information: @ppi,
      watermark: watermark,
      errors: errors
    )

    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva,
      status: status,
      filetype: "pdf"
    )

    File.open(pdf_path, "rb") { |f| log.filepath = f }
    log.save!

    Rails.logger.info("NPDB log saved: #{log.id}, status=#{log.status}")

    log
  end

  def select_query_response_file(
    files,
    submission_filename:
  )
    return nil if files.blank?

    exact_match =
      files.find do |file|
        xml = file[:xml].to_s

        next false unless
          xml.include?("<queryResponse")

        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!

        returned_filename =
          doc
            .at_xpath("//submissionFilename")
            &.text
            .to_s
            .strip

        returned_filename ==
          submission_filename.to_s.strip
      rescue Nokogiri::XML::SyntaxError
        false
      end

    return exact_match if exact_match.present?

    Rails.logger.warn(
      "NPDB exact response not found for " \
      "#{submission_filename.inspect}. " \
      "Received files: " \
      "#{files.map { |f| f[:filename] }.inspect}"
    )

    nil
  end

  def save_response_xml!(response_xml, received_filename = nil)
    return if response_xml.blank?

    safe_filename =
      received_filename.to_s.presence ||
      "NPDB_RESPONSE_#{@npdb.id}_#{Time.current.utc.strftime('%Y%m%d%H%M%S')}.xml"

    safe_filename = File.basename(safe_filename).gsub(/[^A-Za-z0-9_.-]/, "_")
    safe_filename += ".xml" unless safe_filename.downcase.end_with?(".xml")

    path = Rails.root.join("tmp", safe_filename)
    File.write(path, response_xml)

    Rails.logger.info("NPDB response XML saved: #{path}")
  rescue => e
    Rails.logger.error("NPDB XML SAVE ERROR: #{e.class}: #{e.message}")
  end

  def confirmation_failed?(xml)
    doc = Nokogiri::XML(xml)
    doc.remove_namespaces!

    accepted = doc.at_xpath("//accepted")&.text
    errors = doc.xpath("//error")

    accepted == "false" || errors.present?
  end

  def build_submission_xml
    street = normalize_address(@ppi.address_line1.presence || "60 BUCCANEER LN")
    city   = normalize_city(@ppi.city.presence || "SETAUKET")
    state  = normalize_state(@ppi.state.presence || "NY")

    zip5, zip4 =
      normalized_zip_parts(@ppi.zipcode.presence || "117331968")

    ssn = @ppi.ssn.to_s.gsub(/\D/, "")

    cert_name =
      ENV["NPDB_CERT_NAME"].presence ||
      [@ppi.first_name, @ppi.middle_name, @ppi.last_name].compact.join(" ").upcase

    cert_title = ENV["NPDB_CERT_TITLE"].presence || "PHYSICIAN"

    cert_phone =
      ENV["NPDB_CERT_PHONE"].to_s.gsub(/\D/, "").presence || "1234567890"

    birth_date = @ppi.birth_date || @ppi.date_of_birth

    license = selected_license

    license_number =
      license&.license_number.to_s.upcase.gsub(/[^A-Z0-9]/, "")

    license_state = selected_license_state

    occupation_code =
      map_field_code(@ppi.provider_type_provider_type_abbreviation)

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

          <workAddress>
            <address>#{street}</address>
            <city>#{city}</city>
            <state>#{state}</state>
            <zip>#{zip5}</zip>
            #{zip4.present? ? "<zip4>#{zip4}</zip4>" : ""}
          </workAddress>

          <ssn>#{ssn}</ssn>

          <occupationAndLicensure>
            <number>#{license_number}</number>
            <state>#{license_state}</state>
            <field>#{occupation_code}</field>
          </occupationAndLicensure>
        </individual>

      </query:querySubmission>
    XML
  end

  def normalize_address(value)
    value.to_s.upcase.strip
  end

  def normalize_city(value)
    value.to_s.upcase.strip
  end

  def normalize_state(value)
    value.to_s.upcase.strip
  end

  def normalized_zip_parts(value)
    digits = value.to_s.gsub(/\D/, "")

    zip5 = digits.first(5)
    zip4 = digits.length >= 9 ? digits[5, 4] : nil

    [zip5, zip4]
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

  def selected_license
    @selected_license ||= begin
      licenses = @ppi.provider_licensures
      licenses.find(&:is_primary_license) || licenses.first
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

  def map_field_code(value)
    normalized = value.to_s.downcase.strip

    case normalized
    when /md resident/, /physician resident/
      "015"
    when /do resident/, /osteopathic physician resident/
      "025"
    when "medical", /medical doctor/, /physician/, /\bmd\b/
      "010"
    when /osteopathic/, /\bdo\b/
      "020"
    when /dentist/, /\bdds\b/, /\bdmd\b/
      "030"
    when /physician assistant/, /\bpa\b/
      "642"
    when /nurse practitioner/, /\bnp\b/
      "130"
    when /registered nurse/, /\brn\b/
      "100"
    else
      Rails.logger.warn(
        "NPDB occupation field could not be mapped for #{value.inspect}; defaulting to 010"
      )
      "010"
    end
  end

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
      "multipart/related; type=\"application/xop+xml\"; start=\"<rootpart>\"; start-info=\"application/soap+xml\"; boundary=\"#{boundary}\""
    request.body = body

    Rails.logger.info("NPDB REQUEST:\n#{body}")

    response = http.request(request)

    Rails.logger.info("NPDB RESPONSE:\n#{response.body}")

    @send_confirmation_xml = extract_query_confirmation_xml(response.body)

    Rails.logger.info("NPDB SEND CONFIRMATION XML:\n#{@send_confirmation_xml}") if @send_confirmation_xml.present?

    status_code =
      response.body.to_s[
        /<StatusCode>\s*([^<]+)\s*<\/StatusCode>/,
        1
      ].to_s.strip

    status_message =
      response.body.to_s[
        /<StatusMessage>\s*([^<]*)\s*<\/StatusMessage>/,
        1
      ].to_s.strip

    Rails.logger.info(
      "NPDB SEND STATUS => " \
      "code=#{status_code.inspect}, " \
      "message=#{status_message.inspect}"
    )

    [
      status_code.presence,
      status_message.presence
    ]
  end

  def extract_query_confirmation_xml(body)
    text = body.to_s

    match = text.match(
      /<\?xml[^>]*\?>\s*<queryConfirmation[\s\S]*?<\/queryConfirmation>/
    )

    match&.[](0)&.strip
  end

  def receive_poll!(creds, password)
    uri = URI(endpoint)

    files = []

    5.times do |attempt|
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

      http =
        Net::HTTP.new(
          uri.host,
          uri.port
        )

      http.use_ssl = true

      request =
        Net::HTTP::Post.new(
          uri.request_uri
        )

      request["Content-Type"] =
        "application/soap+xml; charset=UTF-8"

      request.body = body

      response =
        http.request(request)

      Rails.logger.info(
        "NPDB RECEIVE RESPONSE:\n#{response.body}"
      )

      doc =
        Nokogiri::XML(
          response.body
        )

      status_code =
        doc.at_xpath(
          "//*[local-name()='StatusCode']"
        )&.text.to_s.strip

      status_message =
        doc.at_xpath(
          "//*[local-name()='StatusMessage']"
        )&.text.to_s.strip

      unless status_code == OK_CODE
        raise(
          "NPDB Receive failed. " \
          "Code=#{status_code.inspect}, " \
          "Message=#{status_message.inspect}"
        )
      end

      expected =
        doc.at_xpath(
          "//*[local-name()='ExpectedNumberOfFiles']"
        )&.text.to_i

      response_nodes =
        doc.xpath(
          "//*[local-name()='ResponseFiles' " \
          "or local-name()='responseFiles']"
        )

      response_nodes.each do |file|
        encoded =
          file.at_xpath(
            ".//*[local-name()='XmlFileData' " \
            "or local-name()='xmlFileData']"
          )&.text.to_s.strip

        next if encoded.blank?

        filename =
          file.at_xpath(
            ".//*[local-name()='FileName' " \
            "or local-name()='fileName']"
          )&.text.to_s.strip

        begin
          decoded_xml =
            Base64.strict_decode64(
              encoded.gsub(/\s+/, "")
            )
        rescue ArgumentError
          decoded_xml =
            Base64.decode64(encoded)
        end

        next if decoded_xml.blank?

        files << {
          filename: filename,
          xml: decoded_xml
        }

        Rails.logger.info(
          "NPDB RECEIVED FILE => " \
          "#{filename.inspect}, " \
          "bytes=#{decoded_xml.bytesize}"
        )
      end

      remaining =
        doc.at_xpath(
          "//*[local-name()='FilesRemaining']"
        )&.text.to_i

      Rails.logger.info(
        "NPDB RECEIVE POLL ##{attempt + 1}: " \
        "expected=#{expected}, " \
        "parsed=#{response_nodes.size}, " \
        "decoded_total=#{files.size}, " \
        "remaining=#{remaining}"
      )

      if expected.positive? &&
         response_nodes.present? &&
         files.blank?

        raise(
          "NPDB returned #{expected} response " \
          "file(s), but none could be decoded."
        )
      end

      break if remaining.zero?

      sleep 3
    end

    files
  end

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

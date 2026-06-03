# frozen_string_literal: true

require "nokogiri"
require "base64"
require "securerandom"
require "fileutils"
require "net/http"
require "uri"
require "cgi"

class Webscraper::NpdbQrxsService
  QA_ENDPOINT   = "https://qa.npdb.hrsa.gov/qrxs/QrxsWebService"
  PROD_ENDPOINT = "https://www.npdb.hrsa.gov/qrxs/QrxsWebService"

  OK_CODE   = "C00"
  NAMESPACE = "http://www.npdb-hipdb.hrsa.gov/QrxsWebService"

  def initialize(provider_npdb:, provider_personal_information:, rva_information:)
    @npdb = provider_npdb
    @ppi  = provider_personal_information
    @rva  = rva_information
    @debug = false
  end

  def call(debug: false)
    @debug = debug
    @send_confirmation_xml = nil

    validate_submission_data!

    creds = resolved_creds!
    submission_xml = build_submission_xml

    debug_xml("NPDB QUERY SUBMISSION XML", submission_xml)

    filename = "QUERY_#{@npdb.id}_#{Time.current.utc.strftime('%Y%m%d%H%M%S')}.xml"

    debug_log("NPDB filename: #{filename}")
    debug_log("NPDB endpoint: #{endpoint}")

    send_code, send_message = send_submission!(creds, creds[:password], filename, submission_xml)

    send_code = "NO_RESPONSE" if send_code.blank?
    send_message = "No status returned from NPDB." if send_message.blank?

    debug_log("NPDB SEND CODE: #{send_code.inspect}")
    debug_log("NPDB SEND MESSAGE: #{send_message.inspect}")

    failed = send_code != OK_CODE
    files = []

    if @send_confirmation_xml.present?
      confirmation_errors = extract_npdb_errors(@send_confirmation_xml)
      accepted = npdb_accepted?(@send_confirmation_xml)

      debug_log("NPDB CONFIRMATION ACCEPTED: #{accepted.inspect}")
      debug_log("NPDB CONFIRMATION ERRORS: #{confirmation_errors.inspect}")

      failed = true if accepted == false
    end

    if !failed
      begin
        files = receive_poll!(creds, creds[:password])
        debug_log("NPDB received files count: #{files.size}")

        files.each_with_index do |file, index|
          debug_log("NPDB response file #{index + 1}: #{file[:filename]}")
          debug_xml("NPDB RESPONSE XML #{index + 1}", file[:xml]) if file[:xml].present?
        end
      rescue => e
        debug_error(e)
        failed = true
        send_code = "RECEIVE_EXCEPTION"
        send_message = "#{e.class}: #{e.message}"
      end
    end

    response_xml =
      if files.present?
        files.first[:xml]
      elsif @send_confirmation_xml.present?
        @send_confirmation_xml
      else
        build_error_xml(send_code, send_message)
      end

    debug_xml("NPDB FINAL XML", response_xml)

    doc = Nokogiri::XML(response_xml)
    doc.remove_namespaces!

    accepted = doc.at_xpath("//accepted")&.text == "true"

    errors = extract_npdb_errors(response_xml)
    errors << send_message if errors.blank? && failed

    pdf_path = Rails.root.join("tmp", "npdb_mmpr_#{@npdb.id}.pdf").to_s
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

    File.open(pdf_path, "rb") { |f| log.filepath = f }
    log.save!

    debug_log("NPDB log saved: #{log.id}, status=#{log.status}")

    log
  rescue => e
    debug_error(e)
    raise
  end

  private

  def validate_submission_data!
    raise "Missing first name" if @ppi.first_name.blank?
    raise "Missing last name" if @ppi.last_name.blank?
    raise "Missing SSN" if ssn_digits.blank?
    raise "Missing birth date" if birth_date.blank?
    raise "Missing address" if @ppi.address_line1.blank?
    raise "Missing city" if @ppi.city.blank?
    raise "Missing state" if @ppi.state.blank?

    unless zip_digits.length == 9
      raise "ERROR 81: Missing valid ZIP+4. Current ZIP is #{@ppi.zipcode.inspect}. NPDB production requires real USPS ZIP+4."
    end

    raise "Missing sex" if sex_value.blank?
    raise "Missing license" unless selected_license.present?
    raise "Missing license number" if selected_license.license_number.blank?
    raise "Missing license state" if selected_license_state.blank?

    if occupation_field_code.blank?
      raise "ERROR B1: Missing or unsupported NPDB Occupation/Field of Licensure for #{@ppi.provider_type_provider_type_abbreviation.inspect}."
    end
  end

  def build_submission_xml
    zip5, zip4 = normalized_zip_parts(@ppi.zipcode)

    cert_name =
      ENV["NPDB_CERT_NAME"].presence ||
      [@ppi.first_name, @ppi.middle_name, @ppi.last_name].compact.join(" ").upcase

    cert_title = ENV["NPDB_CERT_TITLE"].presence || "AUTHORIZED SUBMITTER"
    cert_phone = ENV["NPDB_CERT_PHONE"].to_s.gsub(/\D/, "").presence || "1234567890"

    license = selected_license

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
          <entityDBID>#{xml_escape(ENV["NPDB_DBID"])}</entityDBID>
          #{agent_dbid_xml}
          <vendorID>#{xml_escape(ENV["NPDB_VENDOR_ID"])}</vendorID>
        </submitter>

        <purpose>P</purpose>

        <certification>
          <name>#{xml_escape(cert_name)}</name>
          <title>#{xml_escape(cert_title)}</title>
          <phone>
            <number>#{xml_escape(cert_phone)}</number>
          </phone>
          <date>#{Date.current.strftime("%Y-%m-%d")}</date>
        </certification>

        <individual>
          <name>
            <last>#{xml_escape(@ppi.last_name.to_s.upcase)}</last>
            <first>#{xml_escape(@ppi.first_name.to_s.upcase)}</first>
            #{middle_name_xml}
            #{suffix_xml}
          </name>

          <sex>#{sex_value}</sex>
          #{birthdate_xml(birth_date)}
          <ssn>#{ssn_digits}</ssn>

          <workAddress>
            <address>#{xml_escape(normalize_address(@ppi.address_line1))}</address>
            #{address2_xml}
            <city>#{xml_escape(normalize_city(@ppi.city))}</city>
            <state>#{xml_escape(normalize_state(@ppi.state))}</state>
            <zip>#{zip5}</zip>
            <zip4>#{zip4}</zip4>
          </workAddress>

          <occupationAndLicensure>
            <number>#{xml_escape(license.license_number.to_s.upcase.gsub(/[^A-Z0-9]/, ""))}</number>
            <state>#{xml_escape(selected_license_state)}</state>
            <field>#{xml_escape(occupation_field_code)}</field>
          </occupationAndLicensure>
        </individual>

      </query:querySubmission>
    XML
  end

  def send_submission!(creds, password, filename, xml)
    uri = URI(endpoint)
    boundary = "----=_Part_#{SecureRandom.hex(12)}"

    soap_xml = <<~XML
      <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
        xmlns:qrx="#{NAMESPACE}">
        <soap:Header/>
        <soap:Body>
          <qrx:Send>
            <qrx:DataBankID>#{xml_escape(creds[:agent_dbid].presence || creds[:dbid])}</qrx:DataBankID>
            <qrx:Password>#{xml_escape(password)}</qrx:Password>
            <qrx:UserID>#{xml_escape(creds[:user_id])}</qrx:UserID>
            <qrx:SubmissionFiles>
              <FileName>#{xml_escape(filename)}</FileName>
              <XmlFileData>
                <inc:Include href="cid:query" xmlns:inc="http://www.w3.org/2004/08/xop/include"/>
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

    debug_xml("NPDB SOAP SEND REQUEST", body)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 120

    request = Net::HTTP::Post.new(uri.request_uri)
    request["MIME-Version"] = "1.0"
    request["Content-Type"] =
      "multipart/related; type=\"application/xop+xml\"; start=\"<rootpart>\"; start-info=\"application/soap+xml\"; boundary=\"#{boundary}\""
    request.body = body

    response = http.request(request)

    debug_log("NPDB HTTP STATUS: #{response.code} #{response.message}")
    debug_xml("NPDB SOAP SEND RAW RESPONSE", response.body)

    status_code, status_message = parse_qrxs_status(response.body)

    attachments = extract_xml_attachments(response.body)
    @send_confirmation_xml = attachments.first if attachments.present?

    debug_xml("NPDB SEND CONFIRMATION XML", @send_confirmation_xml) if @send_confirmation_xml.present?

    [status_code, status_message]
  rescue => e
    debug_error(e)
    ["EXCEPTION", "#{e.class}: #{e.message}"]
  end

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
              <qrx:DataBankID>#{xml_escape(creds[:agent_dbid].presence || creds[:dbid])}</qrx:DataBankID>
              <qrx:UserID>#{xml_escape(creds[:user_id])}</qrx:UserID>
              <qrx:Password>#{xml_escape(password)}</qrx:Password>
            </qrx:Receive>
          </soap:Body>
        </soap:Envelope>
      XML

      debug_xml("NPDB RECEIVE REQUEST", body)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 30
      http.read_timeout = 120

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/soap+xml; charset=UTF-8"
      request.body = body

      response = http.request(request)

      debug_log("NPDB RECEIVE HTTP STATUS: #{response.code} #{response.message}")
      debug_xml("NPDB RECEIVE RAW RESPONSE", response.body)

      status_code, status_message = parse_qrxs_status(response.body)
      raise "Receive failed: #{status_code} #{status_message}" unless status_code == OK_CODE

      extract_xml_attachments(response.body).each_with_index do |xml, index|
        files << {
          filename: "response_#{index + 1}.xml",
          xml: xml
        }
      end

      doc = Nokogiri::XML(response.body)
      remaining = doc.at_xpath("//*[local-name()='FilesRemaining']")&.text.to_i

      break if remaining.zero?

      sleep 3
    end

    files
  end

  def parse_qrxs_status(body)
    doc = Nokogiri::XML(body.to_s)

    fault = doc.at_xpath("//*[local-name()='Fault']")
    if fault
      return [
        "SOAP_FAULT",
        fault.at_xpath(".//*[local-name()='Text']")&.text.presence || fault.text.squish
      ]
    end

    [
      doc.at_xpath("//*[local-name()='StatusCode']")&.text,
      doc.at_xpath("//*[local-name()='StatusMessage']")&.text
    ]
  end

  def extract_xml_attachments(body)
    body.to_s
        .scan(/<\?xml[\s\S]*?(?=\r?\n--uuid:|\r?\n------=_Part_|$)/)
        .map(&:strip)
        .reject { |xml| xml.include?("<S:Envelope") || xml.include?("<soap:Envelope") }
  end

  def extract_npdb_errors(xml)
    doc = Nokogiri::XML(xml.to_s)
    doc.remove_namespaces!

    doc.xpath("//error").map do |e|
      code = e.at_xpath("./code")&.text
      message = e.at_xpath("./message")&.text
      [code, message].compact.join(": ")
    end
  end

  def npdb_accepted?(xml)
    doc = Nokogiri::XML(xml.to_s)
    doc.remove_namespaces!

    value = doc.at_xpath("//subjectConfirmation/accepted")&.text
    return nil if value.blank?

    value == "true"
  end

  def ssn_digits
    @ppi.ssn.to_s.gsub(/\D/, "")
  end

  def zip_digits
    @ppi.zipcode.to_s.gsub(/\D/, "")
  end

  def birth_date
    @ppi.birth_date || @ppi.date_of_birth
  end

  def normalized_zip_parts(value)
    digits = value.to_s.gsub(/\D/, "")
    raise "ERROR 81: Missing valid ZIP+4. Current ZIP is #{value.inspect}." unless digits.length == 9

    [digits[0, 5], digits[5, 4]]
  end

  def birthdate_xml(date)
    raise "Missing birth date" if date.blank?

    date =
      case date
      when Date
        date
      when Time, ActiveSupport::TimeWithZone
        date.to_date
      else
        Date.parse(date.to_s)
      end

    "<birthdate>#{date.strftime('%Y-%m-%d')}</birthdate>"
  end

  def sex_value
    value = @ppi.gender.to_s.strip.downcase
    return "M" if value.start_with?("m")
    return "F" if value.start_with?("f")

    nil
  end

  def selected_license
    @selected_license ||= begin
      licenses = @ppi.provider_licensures
      licenses.find(&:is_primary_license) || licenses.first
    end
  end

  def selected_license_state
    State.find_by(id: selected_license&.state_id)&.alpha_code.to_s.upcase.presence
  end

  def occupation_field_code
    map_field_code(@ppi.provider_type_provider_type_abbreviation.presence || selected_license&.license_type)
  end

  def map_field_code(value)
    case value.to_s.downcase.strip
    when /medical doctor/, /\bmd\b/
      "114"
    when /osteopathic/, /\bdo\b/
      "115"
    when /dentist/, /\bdds\b/, /\bdmd\b/
      "122"
    when /nurse practitioner/, /\bnp\b/
      "117"
    when /physician assistant/, /\bpa\b/
      "118"
    when /registered nurse/, /\brn\b/
      "119"
    else
      nil
    end
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

  def middle_name_xml
    return "" if @ppi.middle_name.blank?

    "<middle>#{xml_escape(@ppi.middle_name.to_s.upcase)}</middle>"
  end

  def suffix_xml
    return "" if @ppi.suffix.blank?

    "<suffix>#{xml_escape(@ppi.suffix.to_s.upcase)}</suffix>"
  end

  def address2_xml
    return "" if @ppi.address_line2.blank?

    "<address2>#{xml_escape(normalize_address(@ppi.address_line2))}</address2>"
  end

  def agent_dbid_xml
    return "" if ENV["NPDB_AGENT_DBID"].blank?

    "<agentDBID>#{xml_escape(ENV["NPDB_AGENT_DBID"])}</agentDBID>"
  end

  def endpoint
    ENV["NPDB_ENV"].to_s.downcase == "production" ? PROD_ENDPOINT : QA_ENDPOINT
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
        <code>#{xml_escape(code)}</code>
        <message>#{xml_escape(message)}</message>
      </npdbError>
    XML
  end

  def xml_escape(value)
    CGI.escapeHTML(value.to_s)
  end

  def debug_log(message)
    Rails.logger.info(message)
    puts message if @debug
  end

  def debug_error(error)
    Rails.logger.error("NPDB ERROR: #{error.class}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n")) if error.backtrace.present?

    return unless @debug

    puts "\nNPDB ERROR: #{error.class}: #{error.message}"
    puts error.backtrace.join("\n") if error.backtrace.present?
  end

  def debug_xml(title, xml)
    return if xml.blank?

    Rails.logger.info("#{title}:\n#{xml}")

    return unless @debug

    puts "\n===== #{title} ====="
    xml.to_s.each_line.with_index(1) do |line, number|
      puts format("%04d | %s", number, line.rstrip)
    end
    puts "===== END #{title} =====\n"
  end
end

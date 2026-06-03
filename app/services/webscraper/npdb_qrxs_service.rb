# frozen_string_literal: true

require "nokogiri"
require "base64"
require "net/http"
require "uri"
require "cgi"

class Webscraper::NpdbQrxsService
  QA_ENDPOINT   = "https://qa.npdb.hrsa.gov/qrxs/QrxsWebService"
  PROD_ENDPOINT = "https://www.npdb.hrsa.gov/qrxs/QrxsWebService"
  OK_CODE       = "C00"
  NAMESPACE     = "http://www.npdb-hipdb.hrsa.gov/QrxsWebService"

  def initialize(provider_npdb:, provider_personal_information:, rva_information:)
    @npdb = provider_npdb
    @ppi  = provider_personal_information
    @rva  = rva_information
  end

  def call(debug: false)
    @debug = debug

    validate_submission_data!
    validate_npdb_payload!

    creds = resolved_creds!
    submission_xml = build_submission_xml

    debug_xml("NPDB QUERY SUBMISSION XML", submission_xml)

    filename = "QUERY_#{@npdb.id}_#{Time.current.utc.strftime('%Y%m%d%H%M%S')}.xml"
    debug_log("NPDB filename: #{filename}")
    debug_log("NPDB endpoint: #{endpoint}")

    send_code, send_message =
      send_submission!(creds, creds[:password], filename, submission_xml)

    send_code = "NO_RESPONSE" if send_code.blank?
    send_message = "No response/status returned from NPDB send_submission!. Check SOAP request/response parsing." if send_message.blank?

    debug_log("NPDB SEND CODE: #{send_code.inspect}")
    debug_log("NPDB SEND MESSAGE: #{send_message.inspect}")

    failed = send_code != OK_CODE
    files = []

    unless failed
      begin
        files = receive_poll!(creds, creds[:password])
        debug_log("NPDB received files count: #{files.size}")

        files.each_with_index do |file, index|
          debug_log("NPDB response file #{index + 1}: #{file[:filename] || file[:name]}")
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
      else
        build_error_xml(send_code, send_message)
      end

    debug_xml("NPDB FINAL RESPONSE XML", response_xml)

    pdf_path = Rails.root.join("tmp", "npdb_mmpr_#{@npdb.id}.pdf").to_s
    FileUtils.rm_f(pdf_path)

    Webscraper::NpdbMmprPdfRenderer.render_to_file!(
      output_path: pdf_path,
      response_xml: response_xml,
      provider_personal_information: @ppi,
      watermark: failed ? "FAILED" : "",
      errors: []
    )

    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva,
      status: failed ? "failed" : "completed",
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

  def validate_submission_data!
    raise "Missing first name" if @ppi.first_name.blank?
    raise "Missing last name" if @ppi.last_name.blank?
    raise "Missing SSN" if ssn_digits.blank?
    raise "Missing birth date" if birth_date.blank?
    raise "Missing address" if @ppi.address_line1.blank?
    raise "Missing city" if @ppi.city.blank?
    raise "Missing state" if @ppi.state.blank?

    unless zip_digits.length == 9
      raise "ERROR 81: Missing ZIP+4. Current ZIP is #{@ppi.zipcode.inspect}. Production NPDB query requires 9-digit ZIP+4."
    end

    raise "Missing sex" if sex_value.blank?
    raise "Missing license" unless selected_license.present?
    raise "Missing license number" if selected_license.license_number.blank?
    raise "Missing license state" if selected_license_state.blank?
    raise "ERROR B1: Missing NPDB occupation/field code" if occupation_field_code.blank?
  end

  def validate_npdb_payload!
    raise "ERROR 81: ZIP must be 9 digits ZIP+4" unless zip_digits.length == 9
    raise "ERROR B1: Incomplete Occupation/Field of Licensure" if occupation_field_code.blank?
  end

  def build_submission_xml
    zip5, zip4 = normalized_zip_parts(@ppi.zipcode)

    cert_name = [
      ENV["NPDB_CERTIFIER_NAME"].presence || @ppi.first_name,
      ENV["NPDB_CERTIFIER_MIDDLE"].presence,
      ENV["NPDB_CERTIFIER_LAST"].presence || @ppi.last_name
    ].compact.join(" ").upcase

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
          <title>#{xml_escape(ENV["NPDB_CERTIFIER_TITLE"].presence || "AUTHORIZED SUBMITTER")}</title>
          <phone>
            <number>#{xml_escape(certifier_phone)}</number>
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

    soap_body = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
        xmlns:qrx="#{NAMESPACE}">
        <soap:Header/>
        <soap:Body>
          <qrx:Send>
            <qrx:DataBankID>#{xml_escape(creds[:dbid])}</qrx:DataBankID>
            <qrx:Password>#{xml_escape(password)}</qrx:Password>
            <qrx:UserID>#{xml_escape(creds[:user_id])}</qrx:UserID>
            <qrx:SubmissionFiles>
              <FileName>#{xml_escape(filename)}</FileName>
              <XmlFileData>#{Base64.strict_encode64(xml)}</XmlFileData>
            </qrx:SubmissionFiles>
          </qrx:Send>
        </soap:Body>
      </soap:Envelope>
    XML

    debug_xml("NPDB SOAP SEND REQUEST", soap_body)

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = 'application/soap+xml; charset=UTF-8; action="Send"'
    request.body = soap_body

    response =
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.open_timeout = 30
        http.read_timeout = 120
        http.request(request)
      end

    debug_log("NPDB HTTP STATUS: #{response.code} #{response.message}")
    debug_xml("NPDB SOAP SEND RAW RESPONSE", response.body)

    unless response.is_a?(Net::HTTPSuccess)
      return ["HTTP_#{response.code}", "HTTP error from NPDB: #{response.code} #{response.message}"]
    end

    parse_qrxs_status(response.body)
  rescue => e
    debug_error(e)
    ["EXCEPTION", "#{e.class}: #{e.message}"]
  end

  def parse_qrxs_status(xml)
    doc = Nokogiri::XML(xml.to_s)
    doc.remove_namespaces!

    fault = doc.at_xpath("//Fault")
    if fault
      fault_message =
        fault.at_xpath(".//Reason//Text")&.text.presence ||
        fault.at_xpath(".//faultstring")&.text.presence ||
        fault.text.squish

      return ["SOAP_FAULT", fault_message]
    end

    code =
      doc.at_xpath("//StatusCode")&.text.presence ||
      doc.at_xpath("//statusCode")&.text.presence ||
      doc.at_xpath("//Code")&.text.presence ||
      doc.at_xpath("//code")&.text.presence

    message =
      doc.at_xpath("//StatusMessage")&.text.presence ||
      doc.at_xpath("//statusMessage")&.text.presence ||
      doc.at_xpath("//Message")&.text.presence ||
      doc.at_xpath("//message")&.text.presence ||
      doc.text.squish

    [code, message]
  end

  def receive_poll!(_creds, _password)
    []
  end

  def birthdate_xml(value)
    date =
      case value
      when Date then value
      when Time, ActiveSupport::TimeWithZone then value.to_date
      else Date.parse(value.to_s)
      end

    "<birthdate>#{date.strftime('%Y-%m-%d')}</birthdate>"
  rescue
    raise "Invalid birth date format"
  end

  def ssn_digits = @ppi.ssn.to_s.gsub(/\D/, "")
  def zip_digits = @ppi.zipcode.to_s.gsub(/\D/, "")
  def birth_date = @ppi.birth_date || @ppi.date_of_birth

  def normalized_zip_parts(value)
    digits = value.to_s.gsub(/\D/, "")
    raise "ERROR 81: ZIP must be 9 digits ZIP+4" unless digits.length == 9
    [digits[0, 5], digits[5, 4]]
  end

  def sex_value
    value = @ppi.gender.to_s.strip.downcase
    return "M" if value.start_with?("m")
    return "F" if value.start_with?("f")
    nil
  end

  def occupation_field_code
    map_field_code(@ppi.provider_type_provider_type_abbreviation.presence || selected_license&.license_type)
  end

  def map_field_code(value)
    case value.to_s.downcase.strip
    when /\bmd\b|medical doctor|physician/ then "114"
    when /\bdo\b|osteopathic/ then "115"
    when /\bdds\b|dentist/ then "122"
    when /\bnp\b|nurse practitioner/ then "117"
    when /\bpa\b|physician assistant/ then "118"
    when /\brn\b|registered nurse/ then "119"
    else nil
    end
  end

  def normalize_address(value)
    value.to_s.upcase.strip.gsub(/\bST\b/, "STREET").gsub(/\bRD\b/, "ROAD").gsub(/\bLN\b/, "LANE")
  end

  def normalize_city(value) = value.to_s.upcase.strip
  def normalize_state(value) = value.to_s.upcase.strip

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

  def certifier_phone
    ENV["NPDB_CERTIFIER_PHONE"].presence ||
      @ppi.telephone_number.to_s.gsub(/\D/, "").presence ||
      "1234567890"
  end

  def selected_license
    @selected_license ||= @ppi.provider_licensures.find(&:is_primary_license) || @ppi.provider_licensures.first
  end

  def selected_license_state
    State.find_by(id: selected_license&.state_id)&.alpha_code&.upcase
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
      <npdbError>
        <status>FAILED</status>
        <code>#{xml_escape(code)}</code>
        <message>#{xml_escape(message)}</message>
      </npdbError>
    XML
  end

  def endpoint
    ENV["NPDB_ENV"].to_s.downcase == "production" ? PROD_ENDPOINT : QA_ENDPOINT
  end

  def xml_escape(value) = CGI.escapeHTML(value.to_s)

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

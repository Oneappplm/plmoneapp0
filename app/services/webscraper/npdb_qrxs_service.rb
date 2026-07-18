# frozen_string_literal: true

require "nokogiri"
require "base64"
require "securerandom"
require "fileutils"
require "net/http"
require "uri"
require "cgi"

class Webscraper::NpdbQrxsService
  QA_ENDPOINT = "https://qa.npdb.hrsa.gov/qrxs/QrxsWebService"
  PROD_ENDPOINT = "https://www.npdb.hrsa.gov/qrxs/QrxsWebService"
  OK_CODE = "C00"
  NAMESPACE = "http://www.npdb-hipdb.hrsa.gov/QrxsWebService"
  RECEIVE_ATTEMPTS = 5
  RECEIVE_DELAY = 3

  def initialize(provider_npdb:, provider_personal_information:, rva_information:)
    @npdb = provider_npdb
    @ppi = provider_personal_information
    @rva = rva_information
  end

  def call
    creds = resolved_creds!
    submission_xml = build_submission_xml
    filename = "QUERY_#{@npdb.id}_#{Time.current.utc.strftime('%Y%m%d%H%M%S')}.xml"

    send_code, send_message = send_submission!(creds, filename, submission_xml)
    failed = send_code != OK_CODE
    response_files = []

    unless failed
      begin
        response_files = receive_poll!(creds)
      rescue StandardError => e
        Rails.logger.error("NPDB RECEIVE ERROR: #{e.class}: #{e.message}")
        failed = true
        send_message = e.message
      end
    end

    response_xml = select_query_response(response_files) || build_error_xml(send_code, send_message)
    Rails.logger.info("NPDB FINAL XML:\n#{response_xml}")

    parsed = parse_response_safely(response_xml)
    errors = extract_errors(response_xml)
    errors << send_message if failed && send_message.present? && errors.exclude?(send_message)

    successfully_processed = parsed[:successfully_processed] == true
    completed = !failed && successfully_processed && errors.blank?

    pdf_path = Rails.root.join("tmp", "npdb_report_#{@npdb.id}_#{Time.current.to_i}.pdf").to_s
    FileUtils.rm_f(pdf_path)

    Webscraper::NpdbMmprPdfRenderer.render_to_file!(
      output_path: pdf_path,
      response_xml: response_xml,
      provider_personal_information: @ppi,
      watermark: completed ? "" : "FAILED",
      errors: errors
    )

    log = NpdbWebcrawlerLog.new(
      provider_npdb: @npdb,
      rva_information: @rva,
      status: completed ? "completed" : "failed",
      filetype: "pdf"
    )

    File.open(pdf_path, "rb") { |file| log.filepath = file }
    log.save!
    log
  ensure
    FileUtils.rm_f(pdf_path) if defined?(pdf_path) && pdf_path.present?
  end

  private

  def build_submission_xml
    street = normalize_address(@ppi.address_line1)
    city = normalize_city(@ppi.city)
    state = normalize_state(@ppi.state)
    zip5, zip4 = normalized_zip_parts(@ppi.zipcode)
    ssn = @ppi.ssn.to_s.gsub(/\D/, "")
    birth_date = @ppi.respond_to?(:birth_date) ? @ppi.birth_date : @ppi.date_of_birth
    license = selected_license
    license_number = license&.license_number.to_s.upcase.gsub(/[^A-Z0-9]/, "")
    license_state = selected_license_state
    occupation_code = map_field_code(@ppi.provider_type_provider_type_abbreviation)

    required = {
      street: street, city: city, state: state, zip: zip5, ssn: ssn,
      birth_date: birth_date, license_number: license_number,
      license_state: license_state, occupation_code: occupation_code
    }
    missing = required.select { |_key, value| value.blank? }.keys
    raise ArgumentError, "Missing NPDB query fields: #{missing.join(', ')}" if missing.any?

    cert_name = ENV["NPDB_CERT_NAME"].presence || [@ppi.first_name, @ppi.middle_name, @ppi.last_name].compact.join(" ").upcase
    cert_title = ENV["NPDB_CERT_TITLE"].presence || "AUTHORIZED SUBMITTER"
    cert_phone = ENV["NPDB_CERT_PHONE"].to_s.gsub(/\D/, "")

    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <query:querySubmission xmlns:query="http://www.npdb-hipdb.hrsa.gov/Query" xmlns:co="http://www.npdb-hipdb.hrsa.gov/Common" xmlns:rqc="http://www.npdb-hipdb.hrsa.gov/ReportQueryCommon" xmlns:rqs="http://www.npdb-hipdb.hrsa.gov/ReportQuerySubject" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <submitter>
          <entityDBID>#{x(ENV["NPDB_DBID"])}</entityDBID>
          <agentDBID>#{x(ENV["NPDB_AGENT_DBID"])}</agentDBID>
          <vendorID>#{x(ENV["NPDB_VENDOR_ID"])}</vendorID>
        </submitter>
        #{payment_xml(cert_name, street, city, state, zip5, zip4)}
        <purpose>P</purpose>
        <certification>
          <name>#{x(cert_name)}</name><title>#{x(cert_title)}</title>
          <phone><number>#{x(cert_phone)}</number></phone>
          <date>#{Date.current.strftime('%Y-%m-%d')}</date>
        </certification>
        <individual>
          <name><last>#{x(@ppi.last_name.to_s.upcase)}</last><first>#{x(@ppi.first_name.to_s.upcase)}</first>#{middle_name_xml}#{suffix_xml}</name>
          <sex>#{x(gender_value)}</sex>
          <birthdate>#{birth_date.strftime('%Y-%m-%d')}</birthdate>
          <ssn>#{x(ssn)}</ssn>
          <workAddress><address>#{x(street)}</address><city>#{x(city)}</city><state>#{x(state)}</state><zip>#{x(zip5)}</zip>#{zip4.present? ? "<zip4>#{x(zip4)}</zip4>" : ""}</workAddress>
          <occupationAndLicensure><number>#{x(license_number)}</number><state>#{x(license_state)}</state><field>#{x(occupation_code)}</field></occupationAndLicensure>
        </individual>
      </query:querySubmission>
    XML
  end

  def payment_xml(cert_name, street, city, state, zip5, zip4)
    return "<payment/>" if ENV["NPDB_CC_NUMBER"].blank?
    <<~XML
      <payment><creditCard><number>#{x(ENV['NPDB_CC_NUMBER'])}</number><expirationDate>#{x(ENV['NPDB_CC_EXPIRATION'])}</expirationDate><cardholderName>#{x(cert_name)}</cardholderName><cardholderAddress><address>#{x(street)}</address><city>#{x(city)}</city><state>#{x(state)}</state><zip>#{x(zip5)}</zip>#{zip4.present? ? "<zip4>#{x(zip4)}</zip4>" : ""}</cardholderAddress></creditCard></payment>
    XML
  end

  def send_submission!(creds, filename, xml)
    boundary = "----=_Part_#{SecureRandom.hex(12)}"
    soap_xml = <<~XML
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:qrx="#{NAMESPACE}"><soap:Header/><soap:Body><qrx:Send><qrx:DataBankID>#{x(creds[:agent_dbid])}</qrx:DataBankID><qrx:Password>#{x(creds[:password])}</qrx:Password><qrx:UserID>#{x(creds[:user_id])}</qrx:UserID><qrx:SubmissionFiles><FileName>#{x(filename)}</FileName><XmlFileData><inc:Include href="cid:query" xmlns:inc="http://www.w3.org/2004/08/xop/include"/></XmlFileData></qrx:SubmissionFiles></qrx:Send></soap:Body></soap:Envelope>
    XML
    body = +""
    body << "--#{boundary}\r\nContent-Type: application/xop+xml; charset=UTF-8; type=\"application/soap+xml; action=\\\"Send\\\"\"\r\nContent-Transfer-Encoding: 8bit\r\nContent-ID: <rootpart>\r\n\r\n#{soap_xml}\r\n"
    body << "--#{boundary}\r\nContent-Type: text/xml; charset=UTF-8\r\nContent-Transfer-Encoding: binary\r\nContent-ID: <query>\r\n\r\n#{xml}\r\n--#{boundary}--\r\n"
    response = post_request(body, "multipart/related; type=\"application/xop+xml\"; start=\"<rootpart>\"; start-info=\"application/soap+xml\"; boundary=\"#{boundary}\"")
    doc = Nokogiri::XML(response.body)
    [xpath_text(doc, "StatusCode"), xpath_text(doc, "StatusMessage")]
  end

  def receive_poll!(creds)
    files = []
    RECEIVE_ATTEMPTS.times do |attempt|
      body = <<~XML
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:qrx="#{NAMESPACE}"><soap:Body><qrx:Receive><qrx:DataBankID>#{x(creds[:agent_dbid])}</qrx:DataBankID><qrx:UserID>#{x(creds[:user_id])}</qrx:UserID><qrx:Password>#{x(creds[:password])}</qrx:Password></qrx:Receive></soap:Body></soap:Envelope>
      XML
      response = post_request(body, "application/soap+xml; charset=UTF-8")
      doc = Nokogiri::XML(response.body)
      code = xpath_text(doc, "StatusCode")
      message = xpath_text(doc, "StatusMessage")
      raise "NPDB Receive failed: #{code} #{message}" unless code == OK_CODE

      doc.xpath("//*[local-name()='responseFile' or local-name()='ResponseFile']").each do |file|
        encoded = file.at_xpath(".//*[local-name()='xmlFileData' or local-name()='XmlFileData']")&.text.to_s.strip
        next if encoded.blank?
        files << { filename: file.at_xpath(".//*[local-name()='fileName' or local-name()='FileName']")&.text, xml: Base64.decode64(encoded) }
      end
      remaining = xpath_text(doc, "FilesRemaining").to_i
      break if remaining.zero? && files.present?
      sleep RECEIVE_DELAY if attempt < RECEIVE_ATTEMPTS - 1
    end
    raise "NPDB Receive completed without a response file" if files.blank?
    files
  end

  def post_request(body, content_type)
    uri = URI(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 90
    request = Net::HTTP::Post.new(uri.request_uri)
    request["MIME-Version"] = "1.0"
    request["Content-Type"] = content_type
    request.body = body
    response = http.request(request)
    Rails.logger.info("NPDB HTTP #{response.code}:\n#{response.body}")
    raise "NPDB HTTP request failed with status #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    response
  end

  def select_query_response(files)
    files.map { |file| file[:xml].to_s }.find { |value| value.include?("<queryResponse") || value.include?(":queryResponse") } || files.first&.dig(:xml)
  end

  def parse_response_safely(xml)
    Webscraper::NpdbMmprXmlParser.new(xml).to_h
  rescue StandardError => e
    Rails.logger.error("NPDB PARSER ERROR: #{e.class}: #{e.message}")
    {}
  end

  def extract_errors(xml)
    doc = Nokogiri::XML(xml.to_s)
    doc.remove_namespaces!
    errors = doc.xpath("//error").map { |node| [node.at_xpath("./code")&.text, node.at_xpath("./message")&.text].compact.join(": ") }.reject(&:blank?)
    errors << doc.at_xpath("//npdbError/message")&.text if doc.at_xpath("//npdbError/message")
    errors.compact.uniq
  end

  def selected_license
    @selected_license ||= @ppi.provider_licensures.find(&:is_primary_license) || @ppi.provider_licensures.first
  end

  def selected_license_state
    State.find_by(id: selected_license&.state_id)&.alpha_code.to_s.upcase
  end

  def map_field_code(value)
    text = value.to_s.downcase
    return "015" if text.match?(/md.*resident|resident.*md/)
    return "025" if text.match?(/do.*resident|resident.*do/)
    return "010" if text.match?(/medical doctor|physician.*md|\bmd\b/)
    return "020" if text.match?(/osteopath|physician.*do|\bdo\b/)
    return "030" if text.match?(/dentist|dds|dmd/)
    return "642" if text.match?(/physician assistant|\bpa\b/)
    return "130" if text.match?(/nurse practitioner|\bnp\b/)
    return "100" if text.match?(/registered nurse|\brn\b/)
    raise ArgumentError, "Unable to map NPDB occupation field for #{value.inspect}"
  end

  def resolved_creds!
    creds = { dbid: ENV["NPDB_DBID"], agent_dbid: ENV["NPDB_AGENT_DBID"], vendor_id: ENV["NPDB_VENDOR_ID"], user_id: ENV["NPDB_USER_ID"], password: ENV["NPDB_PASSWORD"] }
    missing = creds.select { |_key, value| value.blank? }.keys
    raise ArgumentError, "Missing NPDB credentials: #{missing.join(', ')}" if missing.any?
    creds
  end

  def endpoint
    production? ? PROD_ENDPOINT : QA_ENDPOINT
  end

  def production?
    %w[production prod].include?(ENV["NPDB_ENV"].to_s.downcase)
  end

  def normalize_address(value); value.to_s.upcase.strip.gsub(/\s+/, " "); end
  def normalize_city(value); value.to_s.upcase.strip.gsub(/\s+/, " "); end
  def normalize_state(value); value.to_s.upcase.strip; end
  def normalized_zip_parts(value); digits = value.to_s.gsub(/\D/, ""); [digits.first(5), digits.length >= 9 ? digits[5, 4] : nil]; end
  def middle_name_xml; @ppi.middle_name.present? ? "<middle>#{x(@ppi.middle_name.to_s.upcase)}</middle>" : ""; end
  def suffix_xml; @ppi.suffix.present? ? "<suffix>#{x(@ppi.suffix.to_s.upcase)}</suffix>" : ""; end
  def gender_value; @ppi.gender.to_s.upcase.start_with?("F") ? "F" : "M"; end
  def xpath_text(doc, name); doc.at_xpath("//*[local-name()='#{name}']")&.text.to_s.strip; end
  def x(value); CGI.escapeHTML(value.to_s); end

  def build_error_xml(code, message)
    %(<?xml version="1.0" encoding="UTF-8"?><npdbError><status>FAILED</status><code>#{x(code)}</code><message>#{x(message)}</message></npdbError>)
  end
end

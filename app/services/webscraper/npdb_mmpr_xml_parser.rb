# frozen_string_literal: true

require "nokogiri"

class Webscraper::NpdbMmprXmlParser
  FALLBACK_CODES = {
    sex: {
      "M" => "MALE",
      "F" => "FEMALE",
      "U" => "UNKNOWN"
    },
    report_transaction: {
      "I" => "INITIAL",
      "C" => "CORRECTION",
      "V" => "VOID"
    },
    mmpr_relationship: {
      "P" => "INSURANCE COMPANY - PRIMARY INSURER",
      "E" => "INSURANCE COMPANY - EXCESS INSURER",
      "S" => "SELF-INSURED ORGANIZATION",
      "G" => "INSURANCE GUARANTY FUND",
      "M" => "STATE MEDICAL MALPRACTICE PAYMENT FUND - PRIMARY PAYER",
      "O" => "STATE MEDICAL MALPRACTICE PAYMENT FUND - SECONDARY PAYER"
    },
    mmpr_payment_type: {
      "S" => "A SINGLE FINAL PAYMENT",
      "M" => "ONE OF MULTIPLE PAYMENTS",
      "U" => "UNKNOWN PAYMENT TYPE"
    },
    mmpr_payment_result: {
      "J" => "JUDGMENT",
      "S" => "SETTLEMENT",
      "B" => "PAYMENT PRIOR TO SETTLEMENT",
      "O" => "OTHER",
      "U" => "UNKNOWN"
    },
    mmpr_patient_type: {
      "I" => "INPATIENT",
      "O" => "OUTPATIENT",
      "B" => "BOTH",
      "U" => "UNKNOWN"
    },
    mmpr_nature: {
      "001" => "DIAGNOSIS RELATED",
      "010" => "ANESTHESIA RELATED",
      "020" => "SURGERY RELATED",
      "030" => "MEDICATION RELATED",
      "040" => "IV & BLOOD PRODUCTS RELATED",
      "050" => "OBSTETRICS RELATED",
      "060" => "TREATMENT RELATED",
      "070" => "MONITORING RELATED",
      "080" => "EQUIPMENT/PRODUCT RELATED",
      "090" => "OTHER MISCELLANEOUS",
      "100" => "BEHAVIORAL HEALTH RELATED"
    },
    mmpr_specific_allegation: {
      "101" => "FAILURE TO DIAGNOSE",
      "113" => "FAILURE TO TREAT",
      "200" => "DELAY IN DIAGNOSIS",
      "202" => "DELAY IN TREATMENT",
      "305" => "IMPROPER MANAGEMENT",
      "306" => "IMPROPER PERFORMANCE",
      "323" => "WRONG DIAGNOSIS OR MISDIAGNOSIS"
    },
    mmpr_outcome: {
      "01" => "EMOTIONAL INJURY ONLY",
      "02" => "INSIGNIFICANT INJURY",
      "03" => "MINOR TEMPORARY INJURY",
      "04" => "MAJOR TEMPORARY INJURY",
      "05" => "MINOR PERMANENT INJURY",
      "06" => "SIGNIFICANT PERMANENT INJURY",
      "07" => "MAJOR PERMANENT INJURY",
      "08" => "GRAVE PERMANENT INJURY",
      "09" => "DEATH",
      "10" => "CANNOT BE DETERMINED FROM AVAILABLE RECORDS"
    },
    occupation: {
      "010" => "PHYSICIAN (MD)",
      "015" => "PHYSICIAN (MD) - OTHER",
      "020" => "PHYSICIAN (DO)",
      "025" => "PHYSICIAN (DO) - OTHER",
      "030" => "DENTIST (DDS/DMD)",
      "035" => "DENTIST - OTHER"
    },
    dispute_status: {
      "N" => "",
      "Y" => "THIS REPORT HAS BEEN DISPUTED BY THE SUBJECT.",
      "Q" => "RECONSIDERATION REQUESTED."
    }
  }.freeze

  def initialize(response_xml)
    @doc = Nokogiri::XML(response_xml.to_s) { |config| config.nonet.recover }
    @doc.remove_namespaces!
  end

  def to_h
    query = @doc.at_xpath("/queryResponse") || @doc.root
    subject_response = query&.at_xpath("./querySubjectResponse")
    report = subject_response&.at_xpath("./report")

    query_subject = subject_response&.at_xpath("./individual")
    report_subject = report&.at_xpath("./individual")
    contact = report&.at_xpath("./contact")
    latest_contact = report&.at_xpath("./latestContact")
    report_data = report&.at_xpath("./reportData")
    mmpr = report&.at_xpath("./informationReported/mmpr")
    statement = report&.at_xpath("./statement")

    notes = report_data ? report_data.xpath("./notes/note").map { |n| n.text.to_s.strip }.reject(&:blank?) : []
    supplemental = parse_supplemental_notes(notes)

    {
      # ---------------------------------------------------------
      # Query-level data (summary page)
      # ---------------------------------------------------------
      dcn: text(subject_response, "./status/dcn").presence || text(query, "./batchStatus/dcn"),
      process_date: fmt_mmddyyyy(
        text(subject_response, "./status/processDate").presence ||
        text(query, "./batchStatus/processDate")
      ),
      successfully_processed: truthy?(text(subject_response, "./status/successfullyProcessed")),

      submission_filename: text(query, "./submissionFilename"),

      submitter_vendor_id: text(query, "./submitter/vendorID"),
      submitter_entity_dbid: text(query, "./submitter/entityDBID"),
      submitter_agent_dbid: text(query, "./submitter/agentDBID"),

      certification_name: text(query, "./certification/name"),
      certification_title: text(query, "./certification/title"),
      certification_phone: text(query, "./certification/phone/number"),
      certification_date: fmt_mmddyyyy(text(query, "./certification/date")),

      # The authorized organization is not the report/contact entity.
      # Keep an ENV override so existing callers do not need to change.
      authorized_org_name: ENV["NPDB_AUTHORIZED_ORG_NAME"].to_s,
      authorized_agent_name: ENV["NPDB_AUTHORIZED_AGENT_NAME"].to_s,
      authorized_submitter_name: ENV["NPDB_AUTHORIZED_SUBMITTER_NAME"].to_s,

      title_iv: truthy?(text(subject_response, "./processedUnder/titleIV")),
      section_1921: truthy?(text(subject_response, "./processedUnder/section1921")),
      section_1128e: truthy?(text(subject_response, "./processedUnder/section1128e")),

      query_subject_last: text(query_subject, "./name/last"),
      query_subject_first: text(query_subject, "./name/first"),
      query_subject_middle: text(query_subject, "./name/middle"),
      query_subject_suffix: text(query_subject, "./name/suffix"),
      query_sex: lookup(:sex, text(query_subject, "./sex")),
      query_birthdate: fmt_mmddyyyy(text(query_subject, "./birthdate")),
      query_work_addr1: text(query_subject, "./workAddress/address"),
      query_work_addr2: text(query_subject, "./workAddress/address2"),
      query_work_city: text(query_subject, "./workAddress/city"),
      query_work_state: text(query_subject, "./workAddress/state"),
      query_work_zip: zip_with_4(
        text(query_subject, "./workAddress/zip"),
        text(query_subject, "./workAddress/zip4")
      ),
      query_home_addr1: text(query_subject, "./homeAddress/address"),
      query_home_addr2: text(query_subject, "./homeAddress/address2"),
      query_home_city: text(query_subject, "./homeAddress/city"),
      query_home_state: text(query_subject, "./homeAddress/state"),
      query_home_zip: zip_with_4(
        text(query_subject, "./homeAddress/zip"),
        text(query_subject, "./homeAddress/zip4")
      ),
      query_ssn: text(query_subject, "./ssn"),
      query_license_number: text(query_subject, "./occupationAndLicensure/number"),
      query_occupation_state: text(query_subject, "./occupationAndLicensure/state"),
      query_occupation_field_code: text(query_subject, "./occupationAndLicensure/field"),
      query_occupation_field: lookup(:occupation, text(query_subject, "./occupationAndLicensure/field")),

      # ---------------------------------------------------------
      # Report-level header / status
      # ---------------------------------------------------------
      report_dcn: text(report_data, "./reportDCN"),
      transaction_code: text(report_data, "./transaction"),
      transaction: lookup(:report_transaction, text(report_data, "./transaction")),
      previous_dcn: text(report_data, "./previousDCN"),
      original_submission_date: fmt_mmddyyyy(text(report_data, "./originalSubmitDate")),
      most_recent_change_date: fmt_mmddyyyy(text(report_data, "./recentChangeDate")),
      report_process_date: fmt_mmddyyyy(text(report_data, "./originalSubmitDate")),
      maintained_under: report_data ?
        report_data.xpath("./maintainedUnder/statute").map { |n| n.text.to_s.strip }.reject(&:blank?).join("; ") :
        "",

      # ---------------------------------------------------------
      # Reporting entity
      # ---------------------------------------------------------
      entity_name: text(contact, "./entityName"),
      entity_office: text(contact, "./officeOrName"),
      entity_title: text(contact, "./titleOrDept"),
      entity_phone: text(contact, "./phone/number"),
      entity_addr1: text(contact, "./address/address"),
      entity_addr2: text(contact, "./address/address2"),
      entity_city: text(contact, "./address/city"),
      entity_state: text(contact, "./address/state"),
      entity_zip: zip_with_4(
        text(contact, "./address/zip"),
        text(contact, "./address/zip4")
      ),
      entity_country: text(contact, "./address/country"),
      entity_internal_ref: text(contact, "./entityReference").presence ||
        text(contact, "./entityInternalReportReference"),

      latest_contact_present: latest_contact.present?,
      latest_contact_entity_status: text(latest_contact, "./entityStatus"),
      latest_contact_entity_name: text(latest_contact, "./entityName"),
      latest_contact_addr1: text(latest_contact, "./address/address"),
      latest_contact_addr2: text(latest_contact, "./address/address2"),
      latest_contact_city: text(latest_contact, "./address/city"),
      latest_contact_state: text(latest_contact, "./address/state"),
      latest_contact_zip: zip_with_4(
        text(latest_contact, "./address/zip"),
        text(latest_contact, "./address/zip4")
      ),
      latest_contact_country: text(latest_contact, "./address/country"),
      latest_contact_last_update_date: fmt_mmddyyyy(text(latest_contact, "./lastUpdateDate")),

      # ---------------------------------------------------------
      # Report subject (unabridged report section B)
      # ---------------------------------------------------------
      subject_last: text(report_subject, "./name/last").presence || text(query_subject, "./name/last"),
      subject_first: text(report_subject, "./name/first").presence || text(query_subject, "./name/first"),
      subject_middle: text(report_subject, "./name/middle"),
      subject_suffix: text(report_subject, "./name/suffix"),
      other_names: parse_other_names(report_subject),
      sex: lookup(:sex, text(report_subject, "./sex")),
      birthdate: fmt_mmddyyyy(text(report_subject, "./birthdate")),
      org_name: text(report_subject, "./organizationName"),
      work_addr1: text(report_subject, "./workAddress/address"),
      work_addr2: text(report_subject, "./workAddress/address2"),
      work_city: text(report_subject, "./workAddress/city"),
      work_state: text(report_subject, "./workAddress/state"),
      work_zip: zip_with_4(
        text(report_subject, "./workAddress/zip"),
        text(report_subject, "./workAddress/zip4")
      ),
      home_addr1: text(report_subject, "./homeAddress/address"),
      home_addr2: text(report_subject, "./homeAddress/address2"),
      home_city: text(report_subject, "./homeAddress/city"),
      home_state: text(report_subject, "./homeAddress/state"),
      home_zip: zip_with_4(
        text(report_subject, "./homeAddress/zip"),
        text(report_subject, "./homeAddress/zip4")
      ),
      ssn: text(report_subject, "./ssn"),
      npi: text(report_subject, "./npi"),
      professional_school: build_school(report_subject),
      occupation_field_code: text(report_subject, "./occupationAndLicensure/field"),
      occupation_field: lookup(:occupation, text(report_subject, "./occupationAndLicensure/field")),
      occupation_state: text(report_subject, "./occupationAndLicensure/state"),
      license_number: text(report_subject, "./occupationAndLicensure/number"),
      no_license: truthy?(text(report_subject, "./occupationAndLicensure/noLicense")),
      deceased: map_deceased(text(report_subject, "./deceasedDate/isDeceased")),
      hospital_affiliations: parse_simple_list(report_subject, "./hospitalAffiliation"),

      # ---------------------------------------------------------
      # MMPR section C
      # ---------------------------------------------------------
      relationship_code: text(mmpr, "./relationshipOfEntity"),
      relationship: lookup(:mmpr_relationship, text(mmpr, "./relationshipOfEntity")),
      amount_this_payment: money(text(mmpr, "./paymentForThisPractitioner")),
      date_this_payment: fmt_mmddyyyy(text(mmpr, "./paymentDate")),
      payment_type_code: text(mmpr, "./paymentType"),
      payment_type: lookup(:mmpr_payment_type, text(mmpr, "./paymentType")),
      total_paid: money(text(mmpr, "./totalPaymentForThisPractitioner")),
      payment_result_of_code: text(mmpr, "./paymentResultOf"),
      payment_result_of: lookup(:mmpr_payment_result, text(mmpr, "./paymentResultOf")),
      judgment_date: fmt_mmddyyyy(text(mmpr, "./judgmentOrSettlementDate")),
      adjudicative_body_case_number: text(mmpr, "./adjudicativeBodyCaseNumber"),
      adjudicative_body_name: text(mmpr, "./adjudicativeBodyName"),
      court_file_number: text(mmpr, "./courtFileNumber"),
      judgment_desc: text(mmpr, "./judgmentOrSettlementDesc"),
      claimant_count: text(mmpr, "./totalNumberClaimants").presence ||
        text(mmpr, "./totalNumberOfClaimants"),

      other_practitioners_total: money(text(mmpr, "./totalPaymentForAllPractitioners")),
      other_practitioners_count: text(mmpr, "./numberPractitioners"),

      state_fund_payment: payment_made(mmpr&.at_xpath("./stateFundPayment")),
      state_fund_amount: money(
        text(mmpr, "./stateFundPayment/amount").presence ||
        text(mmpr, "./stateFundPaymentAmount")
      ),
      self_insured_payment: payment_made(mmpr&.at_xpath("./selfInsuredOrgPayment")),
      self_insured_amount: money(
        text(mmpr, "./selfInsuredOrgPayment/amount").presence ||
        text(mmpr, "./selfInsuredOrgPaymentAmount")
      ),

      patient_age: patient_age(mmpr&.at_xpath("./patientAge")),
      patient_sex: lookup(:sex, text(mmpr, "./patientSex")),
      patient_type_code: text(mmpr, "./patientType"),
      patient_type: lookup(:mmpr_patient_type, text(mmpr, "./patientType")),
      medical_condition_desc: text(mmpr, "./medicalConditionDesc"),
      procedure_desc: text(mmpr, "./procedureDesc"),

      nature_allegation_code: text(mmpr, "./natureAllegation"),
      nature_allegation: with_code(
        lookup(:mmpr_nature, text(mmpr, "./natureAllegation")),
        text(mmpr, "./natureAllegation")
      ),
      specific_allegation_code: text(mmpr, "./specificAllegation/code"),
      specific_allegation: with_code(
        lookup(:mmpr_specific_allegation, text(mmpr, "./specificAllegation/code")),
        text(mmpr, "./specificAllegation/code")
      ),
      event_date: fmt_mmddyyyy(text(mmpr, "./specificAllegation/date")),
      outcome_code: text(mmpr, "./outcome"),
      outcome: with_code(
        lookup(:mmpr_outcome, text(mmpr, "./outcome")),
        text(mmpr, "./outcome")
      ),
      allegations_desc: text(mmpr, "./allegationsDesc"),

      # ---------------------------------------------------------
      # Statement / report status
      # ---------------------------------------------------------
      dispute_status_code: text(statement, "./disputeStatus"),
      dispute_status: lookup(:dispute_status, text(statement, "./disputeStatus")),
      report_disputed_mark: text(statement, "./disputeStatus").to_s.upcase == "Y" ? "X" : "",
      report_reviewed_reconsidered_mark:
        text(statement, "./disputeStatus").to_s.upcase == "Q" ? "X" : "",

      # ---------------------------------------------------------
      # Supplemental section F
      # ---------------------------------------------------------
      report_notes: notes,
      supplemental_disclaimer: supplemental[:disclaimer],
      supplemental_ssns: supplemental[:ssns],
      supplemental_npis: supplemental[:npis],
      supplemental_licenses: supplemental[:licenses],
      supplemental_dea_numbers: supplemental[:dea_numbers]
    }
  end

  private

  def text(node, xpath)
    return "" unless node

    node.at_xpath(xpath)&.text.to_s.strip
  end

  def truthy?(value)
    %w[true t yes y 1].include?(value.to_s.strip.downcase)
  end

  def build_school(subject)
    return "" unless subject

    school = text(subject, "./professionalSchool/school")
    year = text(subject, "./professionalSchool/graduationYear")

    return "" if school.blank? && year.blank?
    return school if year.blank?

    "#{school} (#{year})"
  end

  def parse_other_names(subject)
    return [] unless subject

    subject.xpath("./otherName").map do |node|
      last = text(node, "./last")
      first = text(node, "./first")
      middle = text(node, "./middle")
      suffix = text(node, "./suffix")
      rest = [first, middle, suffix].reject(&:blank?).join(" ")
      rest.present? ? "#{last}, #{rest}" : last
    end.reject(&:blank?)
  end

  def parse_simple_list(node, xpath)
    return "" unless node

    node.xpath(xpath).map { |n| n.text.to_s.strip }.reject(&:blank?).join("; ")
  end

  def parse_supplemental_notes(notes)
    result = {
      disclaimer: "",
      ssns: [],
      npis: [],
      licenses: [],
      dea_numbers: []
    }

    notes.each do |note|
      case note
      when /\ASupplemental Social Security Number\s*:\s*(.+)\z/i
        result[:ssns] << Regexp.last_match(1).strip
      when /\ASupplemental National Provider Identifier\s*:\s*(.+)\z/i
        result[:npis] << Regexp.last_match(1).strip
      when /\ASupplemental Drug Enforcement Administration \(DEA\) Number\s*:\s*(.+)\z/i
        result[:dea_numbers] << Regexp.last_match(1).strip
      when /\ASupplemental Occupation\/Field of Licensure.*?:\s*(.+)\z/i
        result[:licenses] << parse_supplemental_license(Regexp.last_match(1).strip)
      else
        result[:disclaimer] = note if result[:disclaimer].blank?
      end
    end

    result
  end

  def parse_supplemental_license(value)
    parts = value.split(",").map(&:strip)
    occupation = parts.shift.to_s
    state = parts.pop.to_s
    number = parts.join(", ").to_s

    code = occupation[/\((\d{3})\)\s*\z/, 1]
    label = occupation.sub(/\s*\(\d{3}\)\s*\z/, "").strip

    {
      occupation: label,
      field_code: code,
      number: number,
      state: state,
      raw: value
    }
  end

  def payment_made(node)
    return "" unless node
    return "" if node.children.none? { |child| child.element? }

    value = text(node, "./paymentMade")

    case value.to_s.upcase
    when "Y" then "YES"
    when "N" then "NO"
    else value
    end
  end

  def patient_age(node)
    return "" unless node

    return "UNKNOWN" if truthy?(text(node, "./unknown"))

    years = text(node, "./years")
    months = text(node, "./months")
    days = text(node, "./days")
    value = text(node, "./value")

    return "#{years} YEARS" if years.present?
    return "#{months} MONTHS" if months.present?
    return "#{days} DAYS" if days.present?

    value
  end

  def fmt_mmddyyyy(raw)
    return "" if raw.blank?

    match = raw.to_s.match(/\A(\d{4})-(\d{2})-(\d{2})/)
    return raw.to_s unless match

    "#{match[2]}/#{match[3]}/#{match[1]}"
  end

  def money(raw)
    return "" if raw.blank?

    "$ #{format('%.2f', raw.to_f).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def zip_with_4(zip, zip4)
    zip = zip.to_s.strip
    zip4 = zip4.to_s.strip

    return zip4 if zip.blank?
    return zip if zip4.blank?

    "#{zip}-#{zip4}"
  end

  def map_deceased(value)
    case value.to_s.upcase
    when "Y" then "YES"
    when "N" then "NO"
    else "UNKNOWN"
    end
  end

  def with_code(label, code)
    label = label.to_s.strip
    code = code.to_s.strip

    return label if code.blank?
    return code if label.blank? || label == code
    return label if label.include?("(#{code})")

    "#{label} (#{code})"
  end

  def lookup(kind, code)
    code = code.to_s.strip
    return "" if code.blank?

    service_value = lookup_from_service(kind, code)
    return service_value if service_value.present? && service_value.to_s != code

    FALLBACK_CODES.fetch(kind, {}).fetch(code, service_value.presence || code)
  end

  def lookup_from_service(kind, code)
    return "" unless defined?(Webscraper::NpdbCodeLookup)

    service = Webscraper::NpdbCodeLookup

    candidate_methods = {
      sex: [:sex],
      report_transaction: [:report_transaction, :mmpr_report_type],
      mmpr_relationship: [:mmpr_relationship],
      mmpr_payment_type: [:mmpr_payment_type],
      mmpr_payment_result: [:mmpr_payment_result],
      mmpr_patient_type: [:mmpr_patient_type],
      mmpr_nature: [:mmpr_nature],
      mmpr_specific_allegation: [:mmpr_specific_allegation],
      mmpr_outcome: [:mmpr_outcome],
      occupation: [:occupation],
      dispute_status: [:dispute_status]
    }.fetch(kind, [])

    candidate_methods.each do |method_name|
      next unless service.respond_to?(method_name)

      value = service.public_send(method_name, code)
      return value if value.present?
    rescue StandardError
      next
    end

    ""
  end
end

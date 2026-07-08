# frozen_string_literal: true

require "nokogiri"

class Webscraper::NpdbMmprXmlParser
  def initialize(response_xml)
    @doc = Nokogiri::XML(response_xml.to_s)
    @doc.remove_namespaces!
  end

  def to_h
    reports = parsed_reports

    base_data = {
      root_name: @doc.root&.name,

      dcn: t("//pdsSubjectResponse/status/dcn") ||
           t("//querySubjectResponse/status/dcn") ||
           t("//batchStatus/dcn") ||
           t("//status/dcn") ||
           t("//dcn"),

      process_date: fmt_mmddyyyy(
        t("//pdsSubjectResponse/status/processDate") ||
        t("//querySubjectResponse/status/processDate") ||
        t("//batchStatus/processDate") ||
        t("//status/processDate") ||
        t("//processDate")
      ),

      submitter_vendor_id: t("//submitter/vendorID").to_s,
      submitter_entity_dbid: t("//submitter/entityDBID").to_s,

      certification_name: t("//certification/name"),
      certification_title: t("//certification/title"),
      certification_phone: t("//certification/phone/number"),

      authorized_org_name: t("//report/contact/entityName").to_s,

      charge_reference_number: t("//chargeReceipt/chargeReference/referenceNumber"),
      number_of_subjects: t("//chargeReceipt/numberOfSubjects"),
      number_of_subjects_charged: t("//chargeReceipt/numberOfSubjectsCharged"),
      number_of_subjects_not_processed: t("//chargeReceipt/numberOfSubjectsNotProcessed"),
      number_of_credits_used: t("//chargeReceipt/numberOfCreditsUsed"),
      total_charge: money(t("//chargeReceipt/totalCharge")),

      reports: reports
    }

    first_report = reports.first || legacy_report_hash

    base_data.merge(first_report)
  end

  private

  def parsed_reports
    @doc.xpath("//report").map.with_index(1) do |report, index|
      report_hash(report, index)
    end
  end

  def report_hash(report, index)
    {
      index: index,
      type: report_type(report),

      dcn: tx(report, ".//reportData/reportDCN"),
      process_date: fmt_mmddyyyy(
        tx(report, ".//reportData/recentChangeDate") ||
        tx(report, ".//reportData/originalSubmitDate")
      ),

      report_dcn: tx(report, ".//reportData/reportDCN"),
      transaction: tx(report, ".//reportData/transaction"),
      previous_dcn: tx(report, ".//reportData/previousDCN"),
      previous_transaction: tx(report, ".//reportData/previousTransaction"),
      original_submission_date: fmt_mmddyyyy(tx(report, ".//reportData/originalSubmitDate")),
      most_recent_change_date: fmt_mmddyyyy(tx(report, ".//reportData/recentChangeDate")),
      maintained_under: tx(report, ".//reportData/maintainedUnder/statute"),

      corrected_fields: report.xpath(".//reportData/correctedFields/field").map { |n| n.text.strip }.reject(&:blank?),

      entity_name: tx(report, ".//contact/entityName"),
      additional_entity_name: tx(report, ".//contact/additionalEntityName"),
      entity_office: tx(report, ".//contact/officeOrName"),
      entity_title: tx(report, ".//contact/titleOrDept"),
      entity_phone: tx(report, ".//contact/phone/number"),
      entity_addr1: tx(report, ".//contact/address/address"),
      entity_addr2: tx(report, ".//contact/address/address2"),
      entity_city: tx(report, ".//contact/address/city"),
      entity_state: tx(report, ".//contact/address/state"),
      entity_zip: tx(report, ".//contact/address/zip"),
      entity_internal_ref: tx(report, ".//contact/entityInternalReportReference") ||
                           tx(report, ".//contact/entityReference"),

      subject_last: tx(report, ".//individual/name/last"),
      subject_first: tx(report, ".//individual/name/first"),
      subject_middle: tx(report, ".//individual/name/middle"),
      subject_suffix: tx(report, ".//individual/name/suffix"),

      other_names: parse_other_names(report),

      sex: map_sex(tx(report, ".//individual/sex")),
      birthdate: fmt_mmddyyyy(tx(report, ".//individual/birthdate")),
      org_name: tx(report, ".//individual/organizationName"),

      work_addr1: tx(report, ".//individual/workAddress/address"),
      work_addr2: tx(report, ".//individual/workAddress/address2"),
      work_city: tx(report, ".//individual/workAddress/city"),
      work_state: tx(report, ".//individual/workAddress/state"),
      work_zip: full_zip(
        tx(report, ".//individual/workAddress/zip"),
        tx(report, ".//individual/workAddress/zip4")
      ),

      home_addr1: tx(report, ".//individual/homeAddress/address"),
      home_addr2: tx(report, ".//individual/homeAddress/address2"),
      home_city: tx(report, ".//individual/homeAddress/city"),
      home_state: tx(report, ".//individual/homeAddress/state"),
      home_zip: full_zip(
        tx(report, ".//individual/homeAddress/zip"),
        tx(report, ".//individual/homeAddress/zip4")
      ),

      ssn: tx(report, ".//individual/ssn"),
      itin: tx(report, ".//individual/itin"),
      fein: tx(report, ".//individual/fein"),
      dea: tx(report, ".//individual/dea"),
      upin: tx(report, ".//individual/upin"),
      npi: tx(report, ".//individual/npi"),

      professional_school: build_school_for(report),

      occupation_field: tx(report, ".//individual/occupationAndLicensure/field"),
      occupation_state: tx(report, ".//individual/occupationAndLicensure/state"),
      license_number: tx(report, ".//individual/occupationAndLicensure/number"),
      specialty: tx(report, ".//individual/occupationAndLicensure/specialty"),
      no_license: tx(report, ".//individual/occupationAndLicensure/noLicense").to_s.downcase == "true",

      other_licenses: parse_other_licenses(report),

      deceased: map_deceased(tx(report, ".//individual/deceasedDate/isDeceased")),
      hospital_affiliations: tx(report, ".//individual/hospitalAffiliations") || "",

      supplemental_individual: parse_supplemental_individual(report),

      mmpr: parse_mmpr(report),
      aar: parse_aar(report),

      dispute_status: map_dispute(tx(report, ".//statement/disputeStatus")),
      report_disputed_mark: tx(report, ".//statement/disputeStatus").to_s.upcase == "Y" ? "X" : ""
    }.tap do |h|
      h.merge!(h[:mmpr]) if h[:type] == "MMPR"
      h.merge!(h[:aar]) if h[:type] == "AAR"
    end
  end

  def legacy_report_hash
    {
      type: legacy_report_type,

      entity_name: t("//report/contact/entityName"),
      entity_office: t("//report/contact/officeOrName"),
      entity_title: t("//report/contact/titleOrDept"),
      entity_phone: t("//report/contact/phone/number"),
      entity_addr1: t("//report/contact/address/address"),
      entity_city: t("//report/contact/address/city"),
      entity_state: t("//report/contact/address/state"),
      entity_zip: t("//report/contact/address/zip"),
      entity_internal_ref: t("//report/contact/entityInternalReportReference") || t("//reportData/entityInternalReportReference"),
      transaction: t("//reportData/transaction"),
      previous_dcn: t("//reportData/previousDCN"),
      maintained_under: t("//reportData/maintainedUnder/statute"),

      sex: map_sex(t("//individual/sex")),
      birthdate: fmt_mmddyyyy(t("//individual/birthdate")),
      org_name: t("//individual/organizationName"),
      work_addr1: t("//individual/workAddress/address"),
      work_city: t("//individual/workAddress/city"),
      work_state: t("//individual/workAddress/state"),
      work_zip: t("//individual/workAddress/zip"),
      home_addr1: t("//individual/homeAddress/address"),
      home_city: t("//individual/homeAddress/city"),
      home_state: t("//individual/homeAddress/state"),
      home_zip: t("//individual/homeAddress/zip"),
      ssn: t("//individual/ssn"),
      npi: t("//individual/npi"),
      professional_school: build_school,
      occupation_field: t("//individual/occupationAndLicensure/field"),
      occupation_state: t("//individual/occupationAndLicensure/state"),
      license_number: t("//individual/occupationAndLicensure/number"),
      no_license: t("//individual/occupationAndLicensure/noLicense").to_s.downcase == "true",
      deceased: map_deceased(t("//individual/deceasedDate/isDeceased")),
      hospital_affiliations: t("//individual/hospitalAffiliations") || "",

      relationship: map_relationship(t("//informationReported/mmpr/relationshipOfEntity")),
      amount_this_payment: money(t("//informationReported/mmpr/paymentForThisPractitioner")),
      date_this_payment: fmt_mmddyyyy(t("//informationReported/mmpr/paymentDate")),
      total_paid: money(t("//informationReported/mmpr/totalPaymentForThisPractitioner")),
      payment_result_of: map_payment_result(t("//informationReported/mmpr/paymentResultOf")),
      judgment_date: fmt_mmddyyyy(t("//informationReported/mmpr/judgmentOrSettlementDate")),
      judgment_desc: t("//informationReported/mmpr/judgmentOrSettlementDesc"),
      claimant_count: t("//informationReported/mmpr/totalNumberClaimants") || t("//informationReported/mmpr/totalNumberOfClaimants"),
      other_practitioners_total: money(t("//informationReported/mmpr/totalPaymentForAllPractitioners")) ||
                                 money(t("//informationReported/mmpr/paymentsByThisPayerForOtherPractitioners/totalAmount")),
      other_practitioners_count: t("//informationReported/mmpr/numberPractitioners"),
      state_fund_payment: map_yes_no_unknown(t("//informationReported/mmpr/stateFundPayment/paymentMade")),
      self_insured_payment: map_yes_no_unknown(t("//informationReported/mmpr/selfInsuredOrgPayment/paymentMade")),
      patient_age: patient_age,
      patient_sex: map_sex(t("//informationReported/mmpr/patientSex")),
      patient_type: map_patient_type(t("//informationReported/mmpr/patientType")),
      medical_condition_desc: t("//informationReported/mmpr/medicalConditionDesc"),
      procedure_desc: t("//informationReported/mmpr/procedureDesc"),
      nature_allegation: t("//informationReported/mmpr/natureAllegation"),
      specific_allegation: t("//informationReported/mmpr/specificAllegation/code"),
      event_date: fmt_mmddyyyy(t("//informationReported/mmpr/specificAllegation/date")),
      outcome: t("//informationReported/mmpr/outcome"),
      allegations_desc: t("//informationReported/mmpr/allegationsDesc"),

      dispute_status: map_dispute(t("//statement/disputeStatus")),
      report_disputed_mark: t("//statement/disputeStatus").to_s.upcase == "Y" ? "X" : ""
    }
  end

  def report_type(report)
    return "MMPR" if report.at_xpath(".//informationReported/mmpr")
    return "AAR" if report.at_xpath(".//informationReported/aar")

    "UNKNOWN"
  end

  def legacy_report_type
    return "MMPR" if @doc.at_xpath("//informationReported/mmpr")
    return "AAR" if @doc.at_xpath("//informationReported/aar")

    "QUERY_RESPONSE"
  end

  def parse_mmpr(report)
    node = report.at_xpath(".//informationReported/mmpr")
    return {} unless node

    {
      relationship: map_relationship(tx(node, ".//relationshipOfEntity")),
      amount_this_payment: money(tx(node, ".//paymentForThisPractitioner")),
      date_this_payment: fmt_mmddyyyy(tx(node, ".//paymentDate")),
      payment_type: tx(node, ".//paymentType"),
      total_paid: money(tx(node, ".//totalPaymentForThisPractitioner")),
      payment_result_of: map_payment_result(tx(node, ".//paymentResultOf")),
      judgment_date: fmt_mmddyyyy(tx(node, ".//judgmentOrSettlementDate")),
      judgment_desc: tx(node, ".//judgmentOrSettlementDesc"),
      claimant_count: tx(node, ".//totalNumberClaimants") || tx(node, ".//totalNumberOfClaimants"),
      other_practitioners_total: money(tx(node, ".//totalPaymentForAllPractitioners")) ||
                                 money(tx(node, ".//paymentsByThisPayerForOtherPractitioners/totalAmount")),
      other_practitioners_count: tx(node, ".//numberPractitioners"),
      state_fund_payment: map_yes_no_unknown(tx(node, ".//stateFundPayment/paymentMade")),
      self_insured_payment: map_yes_no_unknown(tx(node, ".//selfInsuredOrgPayment/paymentMade")),
      patient_age: patient_age_for(node),
      patient_sex: map_sex(tx(node, ".//patientSex")),
      patient_type: map_patient_type(tx(node, ".//patientType")),
      medical_condition_desc: tx(node, ".//medicalConditionDesc"),
      procedure_desc: tx(node, ".//procedureDesc"),
      nature_allegation: tx(node, ".//natureAllegation"),
      specific_allegation: tx(node, ".//specificAllegation/code"),
      event_date: fmt_mmddyyyy(tx(node, ".//specificAllegation/date")),
      outcome: tx(node, ".//outcome"),
      allegations_desc: tx(node, ".//allegationsDesc")
    }
  end

  def parse_aar(report)
    node = report.at_xpath(".//informationReported/aar")
    return {} unless node

    {
      action: tx(node, ".//action"),
      classification_code: tx(node, ".//classification/code"),
      finding_date: fmt_mmddyyyy(tx(node, ".//findingDate")),
      narrative: tx(node, ".//narrative"),
      basis_code: tx(node, ".//basis/code")
    }
  end

  def parse_other_names(node)
    node.xpath(".//individual/otherName").map do |name|
      [
        tx(name, "./last"),
        tx(name, "./first"),
        tx(name, "./middle"),
        tx(name, "./suffix")
      ].compact.join(" ")
    end.reject(&:blank?)
  end

  def parse_other_licenses(node)
    node.xpath(".//individual/otherOccupationAndLicensure").map do |lic|
      {
        number: tx(lic, "./number"),
        state: tx(lic, "./state"),
        field: tx(lic, "./field"),
        description: tx(lic, "./description")
      }
    end
  end

  def parse_supplemental_individual(report)
    supp = report.at_xpath(".//supplementalIndividual")
    return {} unless supp

    {
      names: supp.xpath("./name").map do |name|
        [
          tx(name, "./last"),
          tx(name, "./first"),
          tx(name, "./middle"),
          tx(name, "./suffix")
        ].compact.join(" ")
      end.reject(&:blank?)
    }
  end

  def t(xpath)
    v = @doc.at_xpath(xpath)&.text&.strip
    v.presence
  end

  def tx(node, xpath)
    node.at_xpath(xpath)&.text&.strip.presence
  end

  def build_school
    school = t("//professionalSchool/school")
    year   = t("//professionalSchool/graduationYear")
    return "" if school.blank? && year.blank?

    year.present? ? "#{school} (#{year})" : school.to_s
  end

  def build_school_for(node)
    school = tx(node, ".//professionalSchool/school")
    year = tx(node, ".//professionalSchool/graduationYear")
    return "" if school.blank? && year.blank?

    year.present? ? "#{school} (#{year})" : school.to_s
  end

  def fmt_mmddyyyy(raw)
    return "" if raw.blank?

    if raw =~ /^\d{4}-\d{2}-\d{2}/
      y, m, d = raw[0, 10].split("-")
      "#{m}/#{d}/#{y}"
    else
      raw.to_s
    end
  end

  def full_zip(zip, zip4)
    [zip, zip4].compact.reject(&:blank?).join("-")
  end

  def money(raw)
    return "" if raw.blank?

    "$ #{format('%.2f', raw.to_f)}"
  end

  def patient_age
    unk = t("//informationReported/mmpr/patientAge/unknown")
    return "UNKNOWN" if unk.to_s.downcase == "true"

    t("//informationReported/mmpr/patientAge/value").to_s
  end

  def patient_age_for(node)
    return "UNKNOWN" if tx(node, ".//patientAge/unknown").to_s.downcase == "true"

    tx(node, ".//patientAge/value").to_s
  end

  def map_sex(v)
    case v.to_s.upcase
    when "M" then "MALE"
    when "F" then "FEMALE"
    else "UNKNOWN"
    end
  end

  def map_deceased(v)
    case v.to_s.upcase
    when "Y" then "YES"
    when "N" then "NO"
    else "UNKNOWN"
    end
  end

  def map_yes_no_unknown(v)
    case v.to_s.upcase
    when "Y" then "YES"
    when "N" then "NO"
    else "UNKNOWN"
    end
  end

  def map_relationship(v)
    case v.to_s.upcase
    when "P" then "INSURANCE COMPANY - PRIMARY INSURER"
    when "M" then "INSURANCE COMPANY - MALPRACTICE PAYER"
    else v.to_s
    end
  end

  def map_payment_result(v)
    case v.to_s.upcase
    when "J" then "JUDGMENT"
    when "S" then "SETTLEMENT"
    when "B" then "SETTLEMENT"
    else v.to_s
    end
  end

  def map_patient_type(v)
    case v.to_s.upcase
    when "O" then "OUTPATIENT"
    when "I" then "INPATIENT"
    else "UNKNOWN"
    end
  end

  def map_dispute(v)
    case v.to_s.upcase
    when "Y" then "I DISPUTE THIS REPORT"
    when "N" then ""
    else ""
    end
  end
end

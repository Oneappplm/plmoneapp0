# frozen_string_literal: true

require "nokogiri"

class Webscraper::NpdbMmprXmlParser
  def initialize(response_xml)
    @doc = Nokogiri::XML(response_xml)
    @doc.remove_namespaces!
  end

  def to_h
    {
      # header
      dcn: t("//status/dcn") || t("//dcn"),
			process_date: fmt_mmddyyyy(t("//status/processDate") || t("//processDate")),

			submitter_vendor_id: t("//submitter/vendorID").to_s,
			submitter_entity_dbid: t("//submitter/entityDBID").to_s,

			# this is what you want centered + also in header box as org name
			authorized_org_name: t("//report/contact/entityName").to_s,


      # A. entity contact
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

      # B. subject fields (NOTE: name will be overridden by provider record in renderer)
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
      no_license: (t("//individual/occupationAndLicensure/noLicense").to_s.downcase == "true"),
      deceased: map_deceased(t("//individual/deceasedDate/isDeceased")),
      hospital_affiliations: t("//individual/hospitalAffiliations") || "",

      # C. MMPR
      relationship: map_relationship(t("//informationReported/mmpr/relationshipOfEntity")),
      amount_this_payment: money(t("//informationReported/mmpr/paymentForThisPractitioner")),
      date_this_payment: fmt_mmddyyyy(t("//informationReported/mmpr/paymentDate")),
      total_paid: money(t("//informationReported/mmpr/totalPaymentForThisPractitioner")),
      payment_result_of: map_payment_result(t("//informationReported/mmpr/paymentResultOf")),
      judgment_date: fmt_mmddyyyy(t("//informationReported/mmpr/judgmentOrSettlementDate")),
      judgment_desc: t("//informationReported/mmpr/judgmentOrSettlementDesc"),
      claimant_count: t("//informationReported/mmpr/totalNumberClaimants") || t("//informationReported/mmpr/totalNumberOfClaimants"),
      other_practitioners_total: money(t("//informationReported/mmpr/paymentsByThisPayerForOtherPractitioners/totalAmount")),
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

      # D/E
      dispute_status: map_dispute(t("//statement/disputeStatus")),
      report_disputed_mark: (t("//statement/disputeStatus").to_s.upcase == "Y") ? "X" : ""
    }
  end

  private

  def t(xpath)
    v = @doc.at_xpath(xpath)&.text&.strip
    v.presence
  end

  def build_school
    school = t("//professionalSchool/school")
    year   = t("//professionalSchool/graduationYear")
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

  def money(raw)
    return "" if raw.blank?
    "$ #{format('%.2f', raw.to_f)}"
  end

  def patient_age
    unk = t("//informationReported/mmpr/patientAge/unknown")
    return "UNKNOWN" if unk.to_s.downcase == "true"
    t("//informationReported/mmpr/patientAge/value").to_s
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
    else v.to_s
    end
  end

  def map_payment_result(v)
    case v.to_s.upcase
    when "J" then "SETTLEMENT"
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
    when "N" then "NO STATEMENT SUBMITTED"
    else ""
    end
  end
end

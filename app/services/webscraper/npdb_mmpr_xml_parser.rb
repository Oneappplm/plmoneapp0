# frozen_string_literal: true

require "nokogiri"
require "date"

module Webscraper
  class NpdbMmprXmlParser
    attr_reader :xml

    def initialize(xml)
      @xml = xml.to_s
    end

    def to_h
      document = Nokogiri::XML(clean_xml(xml)) { |config| config.nonet.recover }
      document.remove_namespaces!

      root = document.root
      query_subject = root&.at_xpath("./querySubjectResponse")

      result = {
        root_name: root&.name,
        submission_filename: text(root, "./submissionFilename"),
        submitter: parse_submitter(root&.at_xpath("./submitter")),
        certification: parse_certification(root&.at_xpath("./certification")),
        batch_status: parse_status(root&.at_xpath("./batchStatus")),
        charge_receipt: parse_charge_receipt(root&.at_xpath("./chargeReceipt")),
        subject_status: parse_status(query_subject&.at_xpath("./status")),
        processed_under: parse_processed_under(query_subject&.at_xpath("./processedUnder")),
        subject: parse_individual(query_subject&.at_xpath("./individual"))
      }

      reports = query_subject ? query_subject.xpath("./report").map { |node| parse_report(node, result) } : []
      result[:reports] = reports

      flatten_root_fields!(result)
      merge_first_report_for_backward_compatibility!(result, reports.first)
      result
    rescue Nokogiri::XML::SyntaxError => e
      raise ArgumentError, "Invalid NPDB XML: #{e.message}"
    end

    private

    def parse_submitter(node)
      return {} unless node
      {
        entity_dbid: text(node, "./entityDBID"),
        agent_dbid: text(node, "./agentDBID"),
        vendor_id: text(node, "./vendorID")
      }
    end

    def parse_certification(node)
      return {} unless node
      {
        name: text(node, "./name"),
        title: text(node, "./title"),
        phone: text(node, "./phone/number"),
        date: format_date(text(node, "./date"))
      }
    end

    def parse_status(node)
      return {} unless node
      {
        dcn: text(node, "./dcn"),
        process_date: format_date(text(node, "./processDate")),
        successfully_processed: boolean(text(node, "./successfullyProcessed")),
        error_code: text(node, "./error/code"),
        error_message: text(node, "./error/message")
      }
    end

    def parse_charge_receipt(node)
      return {} unless node
      {
        date_charged: format_date(text(node, "./dateCharged")),
        data_bank: text(node, "./chargeReference/dataBank"),
        reference_number: text(node, "./chargeReference/referenceNumber"),
        number_of_subjects: integer(text(node, "./numberOfSubjects")),
        number_of_subjects_charged: integer(text(node, "./numberOfSubjectsCharged")),
        number_of_subjects_not_processed: integer(text(node, "./numberOfSubjectsNotProcessed")),
        price_per_subject: decimal(text(node, "./pricePerSubject")),
        number_of_credits_used: integer(text(node, "./numberOfCreditsUsed")),
        amount_of_credits_used: decimal(text(node, "./amountOfCreditsUsed")),
        total_charge: decimal(text(node, "./totalCharge"))
      }
    end

    def parse_processed_under(node)
      return {} unless node
      {
        title_iv: boolean(text(node, "./titleIV")),
        section_1921: boolean(text(node, "./section1921")),
        section_1128e: boolean(text(node, "./section1128e"))
      }
    end

    def parse_report(node, root_data)
      type = Webscraper::NpdbReportClassifier.classify(node)
      report_data = node.at_xpath("./reportData")
      information = node.at_xpath("./informationReported")
      statement = node.at_xpath("./statement")

      report = {
        type: type,
        category: type,
        report_type: type,
        contact: parse_contact(node.at_xpath("./contact")),
        latest_contact: parse_latest_contact(node.at_xpath("./latestContact")),
        report_data: parse_report_data(report_data),
        subject: parse_individual(node.at_xpath("./individual")),
        statement: parse_statement(statement),
        information_reported: {}
      }

      case type
      when :mmpr
        report[:information_reported] = parse_mmpr(information&.at_xpath("./mmpr"))
        report[:mmpr] = report[:information_reported]
      when :judgment_conviction
        report[:information_reported] = parse_jocr(information&.at_xpath("./jocr"))
        report[:jocr] = report[:information_reported]
      else
        aar_node = information&.at_xpath("./aar")
        report[:information_reported] = parse_aar(aar_node)
        report[:aar] = report[:information_reported] if aar_node
      end

      flatten_report_fields!(report, root_data)
      report
    end

    def parse_contact(node)
      return {} unless node
      address = node.at_xpath("./address")
      {
        entity_name: text(node, "./entityName"),
        office_or_name: text(node, "./officeOrName"),
        title_or_department: text(node, "./titleOrDept"),
        phone: text(node, "./phone/number"),
        address1: text(address, "./address"),
        address2: text(address, "./address2"),
        city: text(address, "./city"),
        state: text(address, "./state"),
        zip: join_zip(text(address, "./zip"), text(address, "./zip4")),
        country: text(address, "./country"),
        entity_reference: text(node, "./entityReference")
      }
    end

    def parse_latest_contact(node)
      return {} unless node
      address = node.at_xpath("./address")
      {
        entity_status: text(node, "./entityStatus"),
        entity_name: text(node, "./entityName"),
        address1: text(address, "./address"),
        address2: text(address, "./address2"),
        city: text(address, "./city"),
        state: text(address, "./state"),
        zip: join_zip(text(address, "./zip"), text(address, "./zip4")),
        country: text(address, "./country"),
        last_update_date: format_date(text(node, "./lastUpdateDate"))
      }
    end

    def parse_report_data(node)
      return {} unless node
      notes = node.xpath("./notes/note").map { |note| note.text.to_s.strip }.reject(&:empty?)
      {
        report_dcn: text(node, "./reportDCN"),
        transaction: text(node, "./transaction"),
        original_submission_date: format_date(text(node, "./originalSubmitDate")),
        most_recent_change_date: format_date(text(node, "./recentChangeDate")),
        maintained_under: node.xpath("./maintainedUnder/statute").map { |n| n.text.to_s.strip }.reject(&:empty?),
        notes: notes,
        supplemental: parse_supplemental_notes(notes)
      }
    end

    def parse_statement(node)
      return {} unless node
      {
        dispute_status: text(node, "./disputeStatus"),
        text: first_present(text(node, "./statementText"), text(node, "./text"), text(node, "./subjectStatement")),
        date_submitted: format_date(first_present(text(node, "./dateSubmitted"), text(node, "./submissionDate"))),
        report_disputed_mark: boolean_or_code(first_present(text(node, "./reportDisputedMark"), text(node, "./disputed"))),
        secretary_review_pending: boolean_or_code(text(node, "./secretaryReviewPending")),
        secretary_review_completed: boolean_or_code(text(node, "./secretaryReviewCompleted")),
        secretary_reconsideration: boolean_or_code(text(node, "./secretaryReconsideration"))
      }
    end

    def parse_individual(node)
      return {} unless node
      name = node.at_xpath("./name")
      work = node.at_xpath("./workAddress")
      home = node.at_xpath("./homeAddress")
      occupation = node.at_xpath("./occupationAndLicensure")
      school = node.at_xpath("./professionalSchool")
      deceased = node.at_xpath("./deceasedDate")

      {
        last_name: text(name, "./last"),
        first_name: text(name, "./first"),
        middle_name: text(name, "./middle"),
        suffix: text(name, "./suffix"),
        other_names: node.xpath("./otherName").map { |n| n.text.to_s.strip }.reject(&:empty?),
        sex_code: text(node, "./sex"),
        sex: lookup(:sex, text(node, "./sex")),
        birthdate: format_date(text(node, "./birthdate")),
        work_address1: text(work, "./address"),
        work_address2: text(work, "./address2"),
        work_city: text(work, "./city"),
        work_state: text(work, "./state"),
        work_zip: join_zip(text(work, "./zip"), text(work, "./zip4")),
        home_address1: text(home, "./address"),
        home_address2: text(home, "./address2"),
        home_city: text(home, "./city"),
        home_state: text(home, "./state"),
        home_zip: join_zip(text(home, "./zip"), text(home, "./zip4")),
        ssn: text(node, "./ssn"),
        npi: text(node, "./npi"),
        organization_name: text(node, "./organizationName"),
        license_number: text(occupation, "./number"),
        occupation_state: text(occupation, "./state"),
        occupation_field_code: text(occupation, "./field"),
        occupation_field: lookup(:occupation, text(occupation, "./field")),
        no_license: boolean(text(occupation, "./noLicense")),
        professional_school: school_value(school),
        deceased: text(deceased, "./isDeceased"),
        deceased_date: format_date(text(deceased, "./date")),
        dea_numbers: node.xpath("./deaNumber").map { |n| n.text.to_s.strip }.reject(&:empty?),
        hospital_affiliations: node.xpath("./hospitalAffiliation").map { |n| n.text.to_s.strip }.reject(&:empty?)
      }
    end

    def parse_mmpr(node)
      return {} unless node
      specific = node.at_xpath("./specificAllegation")
      patient_age = node.at_xpath("./patientAge")
      relationship_code = text(node, "./relationshipOfEntity")
      payment_type_code = text(node, "./paymentType")
      payment_result_code = text(node, "./paymentResultOf")
      patient_type_code = text(node, "./patientType")
      nature_code = text(node, "./natureAllegation")
      specific_code = text(specific, "./code")
      outcome_code = text(node, "./outcome")

      {
        relationship_code: relationship_code,
        relationship: lookup(:mmpr_relationship, relationship_code),
        amount_this_payment: decimal(text(node, "./paymentForThisPractitioner")),
        date_this_payment: format_date(text(node, "./paymentDate")),
        payment_type_code: payment_type_code,
        payment_type: lookup(:mmpr_payment_type, payment_type_code),
        total_paid: decimal(text(node, "./totalPaymentForThisPractitioner")),
        payment_result_of_code: payment_result_code,
        payment_result_of: lookup(:mmpr_payment_result, payment_result_code),
        judgment_date: format_date(text(node, "./judgmentOrSettlementDate")),
        adjudicative_body_case_number: text(node, "./adjudicativeBodyCaseNumber"),
        adjudicative_body_name: text(node, "./adjudicativeBodyName"),
        court_file_number: text(node, "./courtFileNumber"),
        judgment_desc: text(node, "./judgmentOrSettlementDesc"),
        claimant_count: integer(text(node, "./totalNumberClaimants")),
        other_practitioners_total: decimal(text(node, "./totalPaymentForAllPractitioners")),
        other_practitioners_count: integer(text(node, "./numberPractitioners")),
        state_fund_payment: yes_no(text(node, "./stateFundPayment")),
        state_fund_amount: decimal(text(node, "./stateFundPaymentAmount")),
        self_insured_payment: yes_no(text(node, "./selfInsuredOrgPayment")),
        self_insured_amount: decimal(text(node, "./selfInsuredOrgPaymentAmount")),
        patient_age: patient_age_value(patient_age),
        patient_sex_code: text(node, "./patientSex"),
        patient_sex: lookup(:sex, text(node, "./patientSex")),
        patient_type_code: patient_type_code,
        patient_type: lookup(:mmpr_patient_type, patient_type_code),
        medical_condition_desc: text(node, "./medicalConditionDesc"),
        procedure_desc: text(node, "./procedureDesc"),
        nature_allegation_code: nature_code,
        nature_allegation: lookup(:mmpr_nature, nature_code),
        specific_allegation_code: specific_code,
        specific_allegation: lookup(:mmpr_specific_allegation, specific_code),
        specific_allegation_other_desc: text(specific, "./otherDesc"),
        event_date: format_date(text(specific, "./date")),
        outcome_code: outcome_code,
        outcome: lookup(:mmpr_outcome, outcome_code),
        allegations_desc: text(node, "./allegationsDesc")
      }
    end

    def parse_aar(node)
      return {} unless node
      action_code = first_present(text(node, "./action/code"), text(node, "./action"))
      classification_code = first_present(text(node, "./classification/code"), text(node, "./classification"))
      basis_code = first_present(text(node, "./basis/code"), text(node, "./basis"))
      {
        action_code: action_code,
        action: lookup(:aar_action, action_code),
        classification_code: classification_code,
        classification: lookup(:aar_classification, classification_code),
        finding_date: format_date(first_present(text(node, "./findingDate"), text(node, "./actionDate"))),
        action_date: format_date(text(node, "./actionDate")),
        basis_code: basis_code,
        basis: lookup(:aar_basis, basis_code),
        narrative: first_present(text(node, "./narrativeDescription"), text(node, "./description"), text(node, "./narrative"))
      }
    end

    def parse_jocr(node)
      return {} unless node
      {
        action_code: first_present(text(node, "./action/code"), text(node, "./action")),
        classification_code: first_present(text(node, "./classification/code"), text(node, "./classification")),
        finding_date: format_date(first_present(text(node, "./judgmentDate"), text(node, "./convictionDate"), text(node, "./findingDate"))),
        basis_code: first_present(text(node, "./basis/code"), text(node, "./basis")),
        narrative: first_present(text(node, "./narrativeDescription"), text(node, "./description"), text(node, "./narrative")),
        court_name: text(node, "./courtName"),
        court_file_number: text(node, "./courtFileNumber")
      }
    end

    def parse_supplemental_notes(notes)
      result = { ssns: [], npis: [], licenses: [], dea_numbers: [], other_notes: [] }
      notes.each do |note|
        case note
        when /Supplemental Social Security Number\s*:\s*(.+)\z/i
          result[:ssns] << Regexp.last_match(1).strip
        when /Supplemental National Provider Identifier\s*:\s*(.+)\z/i
          result[:npis] << Regexp.last_match(1).strip
        when /Supplemental Drug Enforcement Administration \(DEA\) Number\s*:\s*(.+)\z/i
          result[:dea_numbers] << Regexp.last_match(1).strip
        when /Supplemental Occupation\/Field of Licensure.*?:\s*(.+)\z/i
          result[:licenses] << parse_supplemental_license(Regexp.last_match(1).strip)
        else
          result[:other_notes] << note
        end
      end
      result
    end

    def parse_supplemental_license(value)
      parts = value.split(",").map(&:strip)
      occupation_part = parts.shift.to_s
      state = parts.pop
      number = parts.join(", ").presence
      code = occupation_part[/\((\d{3})\)\s*\z/, 1]
      occupation_name = occupation_part.sub(/\s*\(\d{3}\)\s*\z/, "").strip
      { field: code, occupation: occupation_name, number: number, state: state, raw: value }
    end

    def flatten_root_fields!(result)
      subject = result[:subject] || {}
      status = result[:subject_status].presence || result[:batch_status] || {}
      certification = result[:certification] || {}
      processed = result[:processed_under] || {}
      submitter = result[:submitter] || {}
      result.merge!(
        dcn: status[:dcn], process_date: status[:process_date], successfully_processed: status[:successfully_processed],
        subject_last: subject[:last_name], subject_first: subject[:first_name], subject_middle: subject[:middle_name], subject_suffix: subject[:suffix],
        sex_code: subject[:sex_code], sex: subject[:sex], birthdate: subject[:birthdate],
        work_addr1: subject[:work_address1], work_addr2: subject[:work_address2], work_city: subject[:work_city], work_state: subject[:work_state], work_zip: subject[:work_zip],
        home_addr1: subject[:home_address1], home_addr2: subject[:home_address2], home_city: subject[:home_city], home_state: subject[:home_state], home_zip: subject[:home_zip],
        ssn: subject[:ssn], npi: subject[:npi], org_name: subject[:organization_name],
        occupation_field_code: subject[:occupation_field_code], occupation_field: subject[:occupation_field], occupation_state: subject[:occupation_state],
        license_number: subject[:license_number], no_license: subject[:no_license], professional_school: subject[:professional_school], deceased: subject[:deceased],
        dea: Array(subject[:dea_numbers]).join(", "), hospital_affiliations: Array(subject[:hospital_affiliations]).join("; "),
        certification_name: certification[:name], certification_title: certification[:title], certification_phone: certification[:phone], certification_date: certification[:date],
        title_iv: processed[:title_iv], section_1921: processed[:section_1921], section_1128e: processed[:section_1128e],
        entity_dbid: submitter[:entity_dbid], agent_dbid: submitter[:agent_dbid], vendor_id: submitter[:vendor_id]
      )
    end

    def flatten_report_fields!(report, root_data)
      contact = report[:contact] || {}
      latest = report[:latest_contact] || {}
      report_data = report[:report_data] || {}
      subject = report[:subject] || {}
      statement = report[:statement] || {}
      info = report[:information_reported] || {}
      supplemental = report_data[:supplemental] || {}

      report.merge!(
        dcn: root_data.dig(:subject_status, :dcn) || root_data.dig(:batch_status, :dcn),
        process_date: root_data.dig(:subject_status, :process_date) || root_data.dig(:batch_status, :process_date),
        authorized_org_name: root_data.dig(:certification, :name),
        report_dcn: report_data[:report_dcn], transaction: report_data[:transaction],
        original_submission_date: report_data[:original_submission_date], most_recent_change_date: report_data[:most_recent_change_date],
        maintained_under: Array(report_data[:maintained_under]).join(", "), report_notes: report_data[:notes], supplemental_notes: report_data[:notes],
        other_licenses: supplemental[:licenses], supplemental_ssns: supplemental[:ssns], supplemental_npis: supplemental[:npis], supplemental_dea_numbers: supplemental[:dea_numbers],
        entity_name: contact[:entity_name], entity_office: contact[:office_or_name], entity_title: contact[:title_or_department], entity_phone: contact[:phone],
        entity_addr1: contact[:address1], entity_addr2: contact[:address2], entity_city: contact[:city], entity_state: contact[:state], entity_zip: contact[:zip],
        entity_country: contact[:country], entity_internal_ref: contact[:entity_reference],
        latest_contact_entity_status: latest[:entity_status], latest_contact_entity_name: latest[:entity_name], latest_contact_addr1: latest[:address1],
        latest_contact_addr2: latest[:address2], latest_contact_city: latest[:city], latest_contact_state: latest[:state], latest_contact_zip: latest[:zip],
        latest_contact_country: latest[:country], latest_contact_last_update_date: latest[:last_update_date],
        subject_last: subject[:last_name], subject_first: subject[:first_name], subject_middle: subject[:middle_name], subject_suffix: subject[:suffix], other_names: subject[:other_names],
        sex_code: subject[:sex_code], sex: subject[:sex], birthdate: subject[:birthdate],
        work_addr1: subject[:work_address1], work_addr2: subject[:work_address2], work_city: subject[:work_city], work_state: subject[:work_state], work_zip: subject[:work_zip],
        home_addr1: subject[:home_address1], home_addr2: subject[:home_address2], home_city: subject[:home_city], home_state: subject[:home_state], home_zip: subject[:home_zip],
        ssn: subject[:ssn], npi: subject[:npi], org_name: subject[:organization_name], occupation_field_code: subject[:occupation_field_code],
        occupation_field: subject[:occupation_field], occupation_state: subject[:occupation_state], license_number: subject[:license_number], no_license: subject[:no_license],
        professional_school: subject[:professional_school], deceased: subject[:deceased],
        dea: (Array(subject[:dea_numbers]) + Array(supplemental[:dea_numbers])).reject(&:blank?).uniq.join(", "),
        hospital_affiliations: Array(subject[:hospital_affiliations]).join("; "),
        dispute_status_code: statement[:dispute_status], dispute_status: lookup(:dispute_status, statement[:dispute_status]),
        subject_statement: statement[:text], subject_statement_date: statement[:date_submitted], report_disputed_mark: statement[:report_disputed_mark],
        secretary_review_pending: statement[:secretary_review_pending], secretary_review_completed: statement[:secretary_review_completed],
        secretary_reconsideration: statement[:secretary_reconsideration]
      )
      report.merge!(info)
    end

    def merge_first_report_for_backward_compatibility!(result, report)
      return unless report
      protected_keys = %i[dcn process_date successfully_processed reports subject subject_status batch_status certification charge_receipt processed_under submitter]
      report.each do |key, value|
        next if protected_keys.include?(key)
        next if value.nil?
        next if value.respond_to?(:empty?) && value.empty?
        result[key] = value
      end
      flatten_root_fields!(result)
    end

    def lookup(method, code)
      return "" if code.blank?
      service = Webscraper::NpdbCodeLookup
      return code.to_s unless service.respond_to?(method)
      value = service.public_send(method, code)
      value.presence || code.to_s
    rescue StandardError
      code.to_s
    end

    def school_value(node)
      return "" unless node
      [text(node, "./school"), text(node, "./graduationYear")].reject(&:blank?).join(", ")
    end

    def patient_age_value(node)
      return "" unless node
      years = text(node, "./years")
      months = text(node, "./months")
      days = text(node, "./days")
      return "#{years} YEARS" if years.present?
      return "#{months} MONTHS" if months.present?
      return "#{days} DAYS" if days.present?
      text(node, ".")
    end

    def yes_no(value)
      normalized = value.to_s.strip.upcase
      return "" if normalized.empty?
      return "YES" if %w[Y YES TRUE 1].include?(normalized)
      return "NO" if %w[N NO FALSE 0].include?(normalized)
      value.to_s
    end

    def boolean_or_code(value)
      normalized = value.to_s.strip
      return nil if normalized.empty?
      bool = boolean(normalized)
      bool.nil? ? normalized : bool
    end

    def boolean(value)
      normalized = value.to_s.strip.downcase
      return true if %w[true t yes y 1].include?(normalized)
      return false if %w[false f no n 0].include?(normalized)
      nil
    end

    def integer(value)
      return nil if value.blank?
      Integer(value)
    rescue ArgumentError, TypeError
      nil
    end

    def decimal(value)
      return nil if value.blank?
      value.to_s.gsub(/[^\d.\-]/, "").to_f
    end

    def format_date(value)
      raw = value.to_s.strip
      return "" if raw.empty?
      date_part = raw[/\A\d{4}-\d{2}-\d{2}/]
      return Date.strptime(date_part, "%Y-%m-%d").strftime("%m/%d/%Y") if date_part
      Date.parse(raw).strftime("%m/%d/%Y")
    rescue ArgumentError
      raw
    end

    def join_zip(zip, zip4)
      base = zip.to_s.strip
      extension = zip4.to_s.strip
      return extension if base.empty?
      return base if extension.empty?
      "#{base}-#{extension}"
    end

    def first_present(*values)
      values.find(&:present?)
    end

    def text(node, xpath)
      return "" unless node
      node.at_xpath(xpath)&.text.to_s.strip
    end

    def clean_xml(value)
      start_index = value.index("<?xml") || value.index("<queryResponse")
      start_index ? value[start_index..] : value
    end
  end
end

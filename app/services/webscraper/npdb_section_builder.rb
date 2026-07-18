# frozen_string_literal: true

module Webscraper
  class NpdbSectionBuilder
    SUMMARY_TYPES = [
      [:mmpr, "Medical Malpractice Payment Report"],
      [:state_licensure, "State Licensure or Certification Action"],
      [:professional_society, "Professional Society Action(s)"],
      [:exclusion_debarment, "Exclusion or Debarment Action(s)"],
      [:dea_federal, "DEA/Federal Licensure Action(s)"],
      [:government_administrative, "Government Administrative Action(s)"],
      [:clinical_privileges, "Clinical Privileges Action(s)"],
      [:judgment_conviction, "Judgment or Conviction Report(s)"],
      [:health_plan, "Health Plan Action(s)"],
      [:peer_review, "Peer Review Organization Action(s)"]
    ].freeze

    class << self
      def build(data)
        reports = Array(data[:reports]).map { |report| normalize_report(report) }

        {
          summary: build_summary(data, reports),
          reports: reports
        }
      end

      def build_summary(data, reports)
        {
          title: query_title(data),
          subject: subject_rows(data),
          query: query_rows(data),
          statuses: summary_statuses(reports),
          cards: reports.map { |report| report_card(report) }
        }
      end

      def normalize_report(report)
        result = deep_symbolize(report || {})
        result[:type] = normalized_type(result)
        result[:title] = report_title(result[:type])
        result[:header] = report_header(result)
        result[:reporting_entity] = reporting_entity_rows(result)
        result[:subject] = subject_rows(result)
        result[:information] = information_rows(result)
        result[:statement] = statement_rows(result)
        result[:status] = status_rows(result)
        result[:supplemental] = supplemental_rows(result)
        result
      end

      def summary_statuses(reports)
        present = reports.map { |report| report[:type] }

        SUMMARY_TYPES.map do |type, label|
          {
            type: type,
            label: label,
            present: present.include?(type),
            status: present.include?(type) ? "Yes, See Below" : "No Reports"
          }
        end
      end

      def report_card(report)
        {
          entity_name: latest_entity_name(report),
          title: report[:title],
          basis: summary_basis(report),
          action: summary_action(report),
          action_date: report[:date_this_payment].presence ||
                       report[:finding_date].presence ||
                       report[:action_date],
          dcn: report[:report_dcn].presence || report[:dcn]
        }
      end

      def report_header(report)
        {
          entity_name: latest_entity_name(report),
          title: report[:title],
          date_label: action_date_label(report),
          action: summary_action(report),
          basis: summary_basis(report)
        }
      end

      def reporting_entity_rows(report)
        rows = [
          ["Entity Name:", report[:entity_name]],
          ["Address:", report[:entity_addr1]],
          ["City, State, Zip:", city_state_zip(report[:entity_city], report[:entity_state], report[:entity_zip])],
          ["Country:", report[:entity_country]],
          ["Name or Office:", report[:entity_office]],
          ["Title or Department:", report[:entity_title]],
          ["Telephone:", phone(report[:entity_phone])],
          ["Entity Internal Report Reference:", report[:entity_internal_ref]],
          ["Type of Report:", lookup(:report_transaction, report[:transaction])],
          ["Previous Report Number:", report[:previous_dcn]]
        ]

        if report[:latest_contact_entity_name].present?
          rows += [
            ["Latest Entity Name:", report[:latest_contact_entity_name]],
            ["Latest Address:", report[:latest_contact_addr1]],
            ["Latest City, State, Zip:", city_state_zip(
              report[:latest_contact_city],
              report[:latest_contact_state],
              report[:latest_contact_zip]
            )],
            ["Latest Contact Update Date:", report[:latest_contact_last_update_date]]
          ]
        end

        rows
      end

      def subject_rows(data)
        [
          ["Practitioner Name:", subject_name(data)],
          ["Date of Birth:", data[:birthdate]],
          ["Sex:", data[:sex]],
          ["Work Address:", address(data[:work_addr1], data[:work_city], data[:work_state], data[:work_zip])],
          ["Home Address:", address(data[:home_addr1], data[:home_city], data[:home_state], data[:home_zip])],
          ["Social Security Number:", mask_ssn(data[:ssn])],
          ["National Provider Identifier:", data[:npi]],
          ["Professional School(s):", data[:professional_school]],
          ["Occupation/Field of Licensure:", occupation(data)],
          ["State License Number, State of Licensure:", license_line(data)],
          ["Drug Enforcement Administration (DEA) Numbers:", data[:dea]]
        ]
      end

      def query_rows(data)
        [
          ["Statutes Queried:", statutes(data)],
          ["Query Type:", query_type(data)],
          ["Entity Name:", data[:authorized_org_name].presence || data[:entity_name]],
          ["Authorized Agent:", data[:authorized_agent]],
          ["Authorized Submitter:", authorized_submitter(data)]
        ]
      end

      def information_rows(report)
        case report[:type]
        when :mmpr
          mmpr_rows(report)
        else
          action_rows(report)
        end
      end

      def mmpr_rows(report)
        [
          ["Date of Report:", report[:process_date]],
          ["Relationship of Entity to This Practitioner:", lookup(
            :mmpr_relationship,
            report[:relationship_code].presence || report[:relationship]
          )],
          ["Amount of This Payment for This Practitioner:", money(report[:amount_this_payment])],
          ["Date of This Payment:", report[:date_this_payment]],
          ["This Payment Represents:", lookup(
            :mmpr_payment_type,
            report[:payment_type_code].presence || report[:payment_type]
          )],
          ["Total Amount Paid for This Practitioner:", money(report[:total_paid])],
          ["Payment Result of:", lookup(
            :mmpr_payment_result,
            report[:payment_result_of_code].presence || report[:payment_result_of]
          )],
          ["Date of Settlement, if Any:", report[:judgment_date]],
          ["Adjudicative Body Case Number:", report[:adjudicative_body_case_number]],
          ["Adjudicative Body Name:", report[:adjudicative_body_name]],
          ["Court File Number:", report[:court_file_number]],
          ["Description of Settlement:", report[:judgment_desc]],
          ["Total Amount Paid for All Practitioners:", money(report[:other_practitioners_total])],
          ["Number of Practitioners:", report[:other_practitioners_count]],
          ["Patient's Age at Time of Initial Event:", patient_age(report)],
          ["Patient's Sex:", report[:patient_sex]],
          ["Patient's Type:", lookup(
            :mmpr_patient_type,
            report[:patient_type_code].presence || report[:patient_type]
          )],
          ["Medical Condition:", report[:medical_condition_desc]],
          ["Procedure Performed:", report[:procedure_desc]],
          ["Nature of Allegation:", lookup(
            :mmpr_nature,
            report[:nature_allegation_code].presence || report[:nature_allegation]
          )],
          ["Specific Allegation:", lookup(
            :mmpr_specific_allegation,
            report[:specific_allegation_code].presence || report[:specific_allegation]
          )],
          ["Date of Event:", report[:event_date]],
          ["Outcome:", lookup(
            :mmpr_outcome,
            report[:outcome_code].presence || report[:outcome]
          )],
          ["Description of Allegations:", report[:allegations_desc]]
        ]
      end

      def action_rows(report)
        [
          ["Date of Report:", report[:process_date]],
          ["Action:", lookup(:aar_action, report[:action_code].presence || report[:action])],
          ["Classification:", lookup(:aar_classification, report[:classification_code])],
          ["Finding Date:", report[:finding_date]],
          ["Basis for Action:", lookup(:aar_basis, report[:basis_code])],
          ["Narrative Description:", report[:narrative].presence || report[:description]]
        ]
      end

      def statement_rows(report)
        [
          ["Subject Statement:", report[:subject_statement]],
          ["Dispute Status:", lookup(:dispute_status, report[:dispute_status_code].presence || report[:dispute_status])]
        ]
      end

      def status_rows(report)
        [
          ["Disputed:", truthy?(report[:report_disputed_mark])],
          ["Secretary Review Pending:", truthy?(report[:secretary_review_pending])],
          ["Secretary Review Completed:", truthy?(report[:secretary_review_completed])],
          ["Secretary Reconsideration Requested:", truthy?(report[:secretary_reconsideration])],
          ["Date of Original Submission:", report[:original_submission_date]],
          ["Date of Most Recent Change:", report[:most_recent_change_date]]
        ]
      end

      def supplemental_rows(report)
        rows = []

        Array(report[:supplemental_notes] || report[:report_notes]).each do |note|
          rows << ["Supplemental Information:", note]
        end

        Array(report[:other_licenses]).each do |license|
          rows << [
            "Occupation/Field of Licensure:",
            lookup(:occupation, license[:field])
          ]
          rows << [
            "State License Number, State of Licensure:",
            [license[:number], license[:state]].compact.join(", ")
          ]
        end

        rows
      end

      private

      def normalized_type(report)
        value = report[:category].presence || report[:type].presence || report[:report_type]
        type = Webscraper::NpdbReportClassifier.normalize(value)
        type == :unknown && report[:mmpr].present? ? :mmpr : type
      end

      def report_title(type)
        SUMMARY_TYPES.to_h.fetch(type, type.to_s.tr("_", " ").upcase)
      end

      def summary_action(report)
        if report[:type] == :mmpr
          lookup(
            :mmpr_payment_result,
            report[:payment_result_of_code].presence || report[:payment_result_of]
          )
        else
          lookup(:aar_action, report[:action_code].presence || report[:action])
        end
      end

      def summary_basis(report)
        if report[:type] == :mmpr
          lookup(
            :mmpr_specific_allegation,
            report[:specific_allegation_code].presence || report[:specific_allegation]
          )
        else
          lookup(:aar_basis, report[:basis_code])
        end
      end

      def action_date_label(report)
        date = report[:date_this_payment].presence ||
               report[:finding_date].presence ||
               report[:action_date]

        "Date of Action: #{date}"
      end

      def latest_entity_name(report)
        report[:latest_contact_entity_name].presence ||
          report[:entity_name].presence ||
          report[:authorized_org_name]
      end

      def query_title(data)
        data[:root_name].to_s == "pdsResponse" ?
          "CONTINUOUS QUERY RESPONSE" :
          "ONE-TIME QUERY RESPONSE"
      end

      def query_type(data)
        if data[:root_name].to_s == "pdsResponse"
          "This is a Continuous Query response."
        else
          "This is a One-Time query response. Your organization will only receive future reports on this practitioner if another query is submitted."
        end
      end

      def statutes(data)
        values = []
        values << "Title IV" if data[:title_iv] || data.dig(:processed_under, :title_iv)
        values << "Section 1921" if data[:section_1921] || data.dig(:processed_under, :section_1921)
        values << "Section 1128E" if data[:section_1128e] || data.dig(:processed_under, :section_1128e)
        values.presence&.join("; ") || "Title IV; Section 1921; Section 1128E"
      end

      def authorized_submitter(data)
        [
          data[:certification_name],
          data[:certification_title],
          phone(data[:certification_phone])
        ].reject(&:blank?).join(", ")
      end

      def subject_name(data)
        last = data[:subject_last].to_s.strip
        rest = [
          data[:subject_first].to_s.strip,
          data[:subject_middle].to_s.strip
        ].reject(&:blank?).join(" ")

        rest.present? ? "#{last}, #{rest}" : last
      end

      def occupation(data)
        [
          lookup(:occupation, data[:occupation_field]),
          data[:occupation_state].present? ? "State #{data[:occupation_state]}" : nil
        ].compact.join(" ")
      end

      def license_line(data)
        return "NO LICENSE, #{data[:occupation_state]}" if data[:no_license]

        [
          data[:license_number],
          data[:occupation_state]
        ].compact.reject(&:blank?).join(", ")
      end

      def patient_age(data)
        age = data[:patient_age].to_s.strip
        return age if age.blank? || age.upcase == "UNKNOWN" || age.include?("YEAR")

        "#{age} YEARS"
      end

      def address(street, city, state, zip)
        [
          street.to_s.strip,
          city_state_zip(city, state, zip)
        ].reject(&:blank?).join(", ")
      end

      def city_state_zip(city, state, zip)
        locality = [
          city.to_s.strip,
          state.to_s.strip
        ].reject(&:blank?).join(", ")

        [
          locality,
          zip.to_s.strip
        ].reject(&:blank?).join(" ")
      end

      def phone(value)
        digits = value.to_s.gsub(/\D/, "")
        return value.to_s if digits.length < 10

        "(#{digits[0, 3]}) #{digits[3, 3]}-#{digits[6, 4]}"
      end

      def mask_ssn(value)
        digits = value.to_s.gsub(/\D/, "")
        return value.to_s if digits.length < 4

        "***-**-#{digits[-4, 4]}"
      end

      def money(value)
        return "" if value.blank?

        number = value.to_s.gsub(/[^\d.\-]/, "").to_f
        "$ #{format('%.2f', number).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      end

      def lookup(method, code)
        return "" if code.blank?

        service = Webscraper::NpdbCodeLookup
        return code.to_s unless service.respond_to?(method)

        label = service.public_send(method, code)
        service.display(code, label)
      end

      def truthy?(value)
        ActiveModel::Type::Boolean.new.cast(value)
      end

      def deep_symbolize(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, item), result|
            result[key.to_sym] = deep_symbolize(item)
          end
        when Array
          value.map { |item| deep_symbolize(item) }
        else
          value
        end
      end
    end
  end
end

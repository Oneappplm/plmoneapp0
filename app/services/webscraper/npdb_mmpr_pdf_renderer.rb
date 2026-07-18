# frozen_string_literal: true

require "prawn"
require "fileutils"

module Webscraper
  class NpdbMmprPdfRenderer
    PAGE_SIZE = "LETTER"
    MARGIN = [140, 36, 28, 36]
    WIDTH = 540
    SIDEBAR = 120
    GREY = "D9D9D9"
    LIGHT_GREY = "E6E6E6"
    DARK_GREY = "CFCFCF"

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
      def render_to_file!(output_path:, response_xml:, provider_personal_information:, watermark: "", errors: [])
        FileUtils.mkdir_p(File.dirname(output_path))
        FileUtils.rm_f(output_path)

        parsed_data = Webscraper::NpdbMmprXmlParser.new(response_xml).to_h
        apply_provider_fallbacks!(parsed_data, provider_personal_information)

        document = Webscraper::NpdbSectionBuilder.build(parsed_data)
        reports = Array(document[:reports])

        Prawn::Document.generate(output_path, page_size: PAGE_SIZE, margin: MARGIN) do |pdf|
          pdf.font("Helvetica")
          pdf.font_size(8)

          render_summary(pdf, parsed_data, document[:summary], reports)

          reports.each do |report|
            next if report.blank? || normalized_type(report) == :query_response
            pdf.start_new_page
            render_report(pdf, parsed_data.merge(report), report)
          end

          render_errors(pdf, errors) if reports.blank? && errors.present?
          add_watermark(pdf, watermark) if watermark.present?
        end

        output_path
      end

      private

      def render_summary(pdf, data, summary, reports)
        start_page = pdf.page_number

        pdf.font("Helvetica-Bold")
        pdf.font_size(15)
        pdf.text("#{subject_name(data)} - #{query_title(data)}", align: :center)
        pdf.move_down(8)

        summary_heading(pdf, "A. SUBJECT IDENTIFICATION INFORMATION",
                        "Recipients should verify that subject identified is, in fact, the subject of interest.")
        summary_rows(pdf, summary[:subject].presence || [
          ["Practitioner Name:", subject_name(data)],
          ["Date of Birth:", data[:birthdate]],
          ["Sex:", data[:sex]],
          ["Work Address:", address(data[:work_addr1], data[:work_city], data[:work_state], data[:work_zip])],
          ["Home Address:", address(data[:home_addr1].presence || data[:work_addr1], data[:home_city].presence || data[:work_city], data[:home_state].presence || data[:work_state], data[:home_zip].presence || data[:work_zip])],
          ["Social Security Number:", mask_ssn(data[:ssn])],
          ["License:", license_summary(data)]
        ])

        summary_heading(pdf, "B. QUERY INFORMATION")
        summary_rows(pdf, summary[:query].presence || [
          ["Statutes Queried:", statutes(data)],
          ["Query Type:", query_type(data)],
          ["Entity Name:", data[:authorized_org_name].presence || data[:entity_name]],
          ["Authorized Agent:", data[:authorized_agent]],
          ["Authorized Submitter:", authorized_submitter(data)]
        ])

        summary_heading(pdf, "C. SUMMARY OF REPORTS ON FILE WITH THE NPDB AS OF #{safe(data[:process_date])}")
        report_status_grid(pdf, reports)
        report_cards(pdf, reports)

        pdf.move_down(12)
        center_rule(pdf, "Unabridged Report(s) Follow")

        add_chrome(pdf, data, start_page, pdf.page_number, summary: true)
      end

      def render_report(pdf, root, report)
        start_page = pdf.page_number
        data = root.merge(report[:mmpr] || {}).merge(report[:aar] || {})

        pdf.font("Helvetica-Bold")
        pdf.font_size(15)
        pdf.text(subject_name(data), align: :center)
        pdf.move_down(6)

        case normalized_type(report)
        when :mmpr
          render_mmpr(pdf, data)
        when :judgment_conviction
          render_action_report(pdf, data, "JUDGMENT OR CONVICTION REPORT")
        when :state_licensure
          render_action_report(pdf, data, "STATE LICENSURE OR CERTIFICATION ACTION REPORT")
        when :professional_society
          render_action_report(pdf, data, "PROFESSIONAL SOCIETY ACTION REPORT")
        when :dea_federal
          render_action_report(pdf, data, "DEA/FEDERAL LICENSURE ACTION REPORT")
        when :clinical_privileges
          render_action_report(pdf, data, "CLINICAL PRIVILEGES ACTION REPORT")
        when :government_administrative
          render_action_report(pdf, data, "GOVERNMENT ADMINISTRATIVE ACTION REPORT")
        when :health_plan
          render_action_report(pdf, data, "HEALTH PLAN ACTION REPORT")
        when :peer_review
          render_action_report(pdf, data, "PEER REVIEW ORGANIZATION ACTION REPORT")
        else
          render_action_report(pdf, data, report_title(normalized_type(report)))
        end

        add_chrome(pdf, data, start_page, pdf.page_number, summary: false)
      end

      def render_mmpr(pdf, d)
        report_banner(
          pdf,
          entity_name(d),
          d[:transaction].to_s.upcase == "C" ? "CORRECTION TO MEDICAL MALPRACTICE PAYMENT REPORT" : "MEDICAL MALPRACTICE PAYMENT REPORT",
          "Date of Action: #{safe(d[:date_this_payment].presence || d[:judgment_date])}",
          lookup(:mmpr_payment_result, d[:payment_result_of_code].presence || d[:payment_result_of]),
          lookup(:mmpr_specific_allegation, d[:specific_allegation_code].presence || d[:specific_allegation])
        )

        reporting_entity(pdf, d)
        subject_section(pdf, d)

        rows = [
          "Date of Report: #{safe(d[:process_date])}",
          "Relationship of Entity to This Practitioner: #{lookup(:mmpr_relationship, d[:relationship_code].presence || d[:relationship])}",
          :bold, "PAYMENTS BY THIS PAYER FOR THIS PRACTITIONER",
          "Amount of This Payment for This Practitioner: #{money(d[:amount_this_payment])}",
          "Date of This Payment: #{safe(d[:date_this_payment])}",
          "This Payment Represents: #{lookup(:mmpr_payment_type, d[:payment_type_code].presence || d[:payment_type])}",
          "Total Amount Paid or to Be Paid by This Payer for This Practitioner: #{money(d[:total_paid])}",
          "Payment Result of: #{lookup(:mmpr_payment_result, d[:payment_result_of_code].presence || d[:payment_result_of])}",
          "Date of Settlement, if Any: #{safe(d[:judgment_date])}",
          "Adjudicative Body Case Number: #{safe(d[:adjudicative_body_case_number])}",
          "Adjudicative Body Name: #{safe(d[:adjudicative_body_name])}",
          "Court File Number: #{safe(d[:court_file_number])}",
          "Description of Settlement and Any Conditions, Including Terms of Payment: #{safe(d[:judgment_desc])}",
          :bold, "PAYMENTS BY THIS PAYER FOR OTHER PRACTITIONERS IN THIS CASE",
          "Total Amount Paid or to Be Paid by This Payer for All Practitioners in This Case: #{money(d[:other_practitioners_total])}",
          "Number of Practitioners for Whom This Payer Has Paid or Will Pay in This Case: #{safe(d[:other_practitioners_count])}",
          :bold, "PAYMENTS BY OTHERS FOR THIS PRACTITIONER",
          "Did (or will) a State Guaranty or Excess Fund Make a Payment for This Practitioner in This Case?: #{safe(d[:state_fund_payment])}",
          "Did (or will) a Self-Insured Organization and/or Other Insurance Company Make a Payment for This Practitioner in This Case?: #{safe(d[:self_insured_payment])}",
          :bold, "CLASSIFICATION OF ACT(S) OR OMISSION(S)",
          "Patient's Age at Time of Initial Event: #{patient_age(d)}",
          "Patient's Sex: #{safe(d[:patient_sex])}",
          "Patient's Type: #{lookup(:mmpr_patient_type, d[:patient_type_code].presence || d[:patient_type])}",
          "Description of the Medical Condition With Which the Patient Presented for Treatment: #{safe(d[:medical_condition_desc])}",
          "Description of the Procedure Performed: #{safe(d[:procedure_desc])}",
          "Nature of Allegation: #{lookup(:mmpr_nature, d[:nature_allegation_code].presence || d[:nature_allegation])}",
          "Specific Allegation: #{lookup(:mmpr_specific_allegation, d[:specific_allegation_code].presence || d[:specific_allegation])}",
          "Date of Event Associated With Allegation or Incident: #{safe(d[:event_date])}",
          "Outcome: #{lookup(:mmpr_outcome, d[:outcome_code].presence || d[:outcome])}",
          "Description of the Allegations and Injuries or Illnesses Upon Which the Action or Claim Was Based: #{safe(d[:allegations_desc])}"
        ]
        section(pdf, "C. INFORMATION\nREPORTED", rich_rows(rows))
        common_tail(pdf, d)
      end

      def render_action_report(pdf, d, title)
        report_banner(
          pdf, entity_name(d), title,
          "Date of Action: #{safe(d[:finding_date].presence || d[:action_date])}",
          lookup(:aar_action, d[:action_code].presence || d[:action]),
          lookup(:aar_basis, d[:basis_code])
        )
        reporting_entity(pdf, d)
        subject_section(pdf, d)

        rows = [
          "Date of Report: #{safe(d[:process_date])}",
          "Action: #{lookup(:aar_action, d[:action_code].presence || d[:action])}",
          "Classification: #{lookup(:aar_classification, d[:classification_code])}",
          "Finding Date: #{safe(d[:finding_date])}",
          "Basis for Action: #{lookup(:aar_basis, d[:basis_code])}",
          "Narrative Description: #{safe(d[:narrative].presence || d[:description])}"
        ]
        section(pdf, "C. INFORMATION\nREPORTED", rich_rows(rows))
        common_tail(pdf, d)
      end

      def reporting_entity(pdf, d)
        section(pdf, "A. REPORTING\nENTITY", pair_rows([
          ["Entity Name:", "#{safe(d[:entity_name])}#{d[:latest_contact_entity_name].present? ? ' *' : ''}"],
          ["Address:", d[:entity_addr1]],
          ["City, State, Zip:", city_state_zip(d[:entity_city], d[:entity_state], d[:entity_zip])],
          ["Country:", d[:entity_country]],
          ["Name or Office:", d[:entity_office]],
          ["Title or Department:", d[:entity_title]],
          ["Telephone:", phone(d[:entity_phone])],
          ["Entity Internal Report Reference:", d[:entity_internal_ref]],
          ["Type of Report:", lookup(:report_transaction, d[:transaction])],
          ["Previous Report Number:", d[:previous_dcn]]
        ]))

        return unless d[:latest_contact_entity_name].present?

        section(pdf, "", [
          { text: "*The reporting entity has changed its name or address on file with the NPDB. The following is the entity's most recent contact information reported to the NPDB on #{safe(d[:latest_contact_last_update_date])}:", size: 7, align: :left },
          { text: "Entity Name: #{safe(d[:latest_contact_entity_name])}", align: :left },
          { text: "Address: #{safe(d[:latest_contact_addr1])}", align: :left },
          { text: "City, State, Zip: #{city_state_zip(d[:latest_contact_city], d[:latest_contact_state], d[:latest_contact_zip])}", align: :left }
        ], sidebar: false)
      end

      def subject_section(pdf, d)
        section(pdf, "B. SUBJECT\nIDENTIFICATION\nINFORMATION\n(INDIVIDUAL)", pair_rows([
          ["Subject Name:", subject_name(d)],
          ["Other Name(s) Used:", Array(d[:other_names]).join("; ")],
          ["Sex:", d[:sex]],
          ["Date of Birth:", d[:birthdate]],
          ["Organization Name:", d[:org_name]],
          ["Work Address:", d[:work_addr1]],
          ["City, State, ZIP:", city_state_zip(d[:work_city], d[:work_state], d[:work_zip])],
          ["Home Address:", d[:home_addr1]],
          ["City, State, ZIP:", city_state_zip(d[:home_city], d[:home_state], d[:home_zip])],
          ["Deceased:", d[:deceased]],
          ["Social Security Numbers (SSN):", mask_ssn(d[:ssn])],
          ["National Provider Identifiers (NPI):", d[:npi]],
          ["Professional School(s) & Year(s) of Graduation:", d[:professional_school]],
          ["Occupation/Field of Licensure:", occupation(d)],
          ["State License Number, State of Licensure:", license_line(d)],
          ["Drug Enforcement Administration (DEA) Numbers:", d[:dea]],
          ["Hospital Affiliation(s):", d[:hospital_affiliations]]
        ]))
      end

      def common_tail(pdf, d)
        section(pdf, "D. SUBJECT\nSTATEMENT", [
          { text: "If the subject identified in Section B of this report has submitted a statement, it appears in this section.", align: :left },
          { text: safe(d[:subject_statement]), align: :left }
        ])

        disputed = d[:report_disputed_mark].present?
        section(pdf, "E. REPORT\nSTATUS", [
          { text: "Unless a box below is checked, the subject of this report identified in Section B has not contested this report.", align: :left },
          checkbox("This report has been disputed by the subject identified in Section B.", disputed),
          checkbox("At the request of the subject identified in Section B, this report is being reviewed by the Secretary of the U.S. Department of Health and Human Services. No decision has been reached.", d[:secretary_review_pending]),
          checkbox("The subject has requested reconsideration of the Secretary's decision.", d[:secretary_reconsideration]),
          checkbox("The Secretary's review has been completed.", d[:secretary_review_completed]),
          { text: "Date of Original Submission: #{safe(d[:original_submission_date])}", align: :left },
          { text: "Date of Most Recent Change: #{safe(d[:most_recent_change_date])}", align: :left }
        ])

        supplemental(pdf, d)

        pdf.move_down(8)
        pdf.font("Helvetica-Bold")
        pdf.text("This report is maintained under the provisions of: #{statute(d[:maintained_under])}", size: 8)
        pdf.move_down(5)
        pdf.font("Helvetica")
        pdf.text("The information contained in this report is maintained by the National Practitioner Data Bank for restricted use under applicable federal law and 45 CFR Part 60. All information is confidential and may be used only for the purpose for which it was disclosed.", size: 7)
        end_report(pdf)
      end

      def supplemental(pdf, d)
        rows = []
        Array(d[:supplemental_notes] || d[:report_notes]).each { |n| rows << { text: safe(n), size: 7, align: :left } }
        Array(d[:other_licenses]).each do |lic|
          rows << { text: "Occupation/Field of Licensure: #{lookup(:occupation, lic[:field])}", align: :left }
          rows << { text: "State License Number, State of Licensure: #{[lic[:number], lic[:state]].compact.join(', ')}", align: :left }
        end
        return if rows.blank?
        section(pdf, "F. SUPPLEMENTAL\nSUBJECT\nINFORMATION ON\nFILE WITH DATA\nBANK", rows)
      end

      def report_status_grid(pdf, reports)
        types = reports.map { |r| normalized_type(r) }
        SUMMARY_TYPES.each_slice(2) do |pair|
          y = pdf.cursor
          pair.each_with_index do |(type, label), idx|
            x = idx * 270
            pdf.font("Helvetica")
            pdf.font_size(7)
            pdf.text_box(label, at: [x, y], width: 185, height: 14)
            status = types.include?(type) ? "Yes, See Below" : "No Reports"
            pdf.font(types.include?(type) ? "Helvetica-Bold" : "Helvetica")
            pdf.text_box(status, at: [x + 185, y], width: 80, height: 14)
          end
          pdf.move_down(15)
        end
      end

      def report_cards(pdf, reports)
        reports.each do |r|
          ensure_space(pdf, 65)
          y = pdf.cursor
          pdf.fill_color(LIGHT_GREY)
          pdf.fill_rectangle([14, y], WIDTH - 28, 58)
          pdf.fill_color("000000")
          pdf.stroke_rectangle([14, y], WIDTH - 28, 58)
          pdf.font("Helvetica-Bold")
          pdf.font_size(9)
          pdf.text_box(entity_name(r), at: [20, y - 5], width: WIDTH - 40, height: 12)
          pdf.text_box(report_title(normalized_type(r)), at: [20, y - 18], width: WIDTH - 40, height: 12)
          pdf.font_size(7)
          pdf.text_box("Basis for Action: - #{summary_basis(r)}", at: [20, y - 31], width: 330, height: 12)
          pdf.text_box("Initial Action: - #{summary_action(r)}", at: [20, y - 43], width: 260, height: 12)
          pdf.text_box("Date of Action: #{safe(r[:date_this_payment].presence || r[:finding_date])}", at: [360, y - 43], width: 160, height: 12, align: :right)
          pdf.text_box("DCN: #{safe(r[:report_dcn].presence || r[:dcn])}", at: [130, y - 53], width: 240, height: 10)
          pdf.move_down(66)
        end
      end

      def report_banner(pdf, entity, title, date, initial, basis)
        h = 92
        ensure_space(pdf, h + 6)
        y = pdf.cursor
        pdf.stroke_rectangle([0, y], WIDTH, h)

        pdf.fill_color(LIGHT_GREY)
        pdf.fill_rectangle([0, y], WIDTH, 25)
        pdf.fill_color("000000")
        pdf.font("Helvetica-Bold")
        pdf.font_size(12)
        pdf.text_box(entity, at: [0, y - 2], width: WIDTH, height: 25, align: :center, valign: :center)

        y -= 25
        pdf.fill_color(GREY)
        pdf.fill_rectangle([0, y], WIDTH, 28)
        pdf.fill_color("000000")
        pdf.text_box(title, at: [6, y - 3], width: 370, height: 28, valign: :center)
        pdf.font_size(9)
        pdf.text_box(date, at: [375, y - 3], width: 155, height: 28, align: :right, valign: :center)

        y -= 28
        pdf.fill_color(DARK_GREY)
        pdf.fill_rectangle([0, y], WIDTH, 17)
        pdf.fill_color("000000")
        pdf.font_size(10)
        pdf.text_box("Initial Action", at: [0, y], width: WIDTH / 2, height: 17, align: :center)
        pdf.text_box("Basis for Initial Action", at: [WIDTH / 2, y], width: WIDTH / 2, height: 17, align: :center)

        y -= 17
        pdf.font("Helvetica")
        pdf.font_size(9)
        pdf.text_box("- #{safe(initial)}", at: [6, y - 3], width: WIDTH / 2 - 12, height: 20)
        pdf.text_box("- #{safe(basis)}", at: [WIDTH / 2 + 6, y - 3], width: WIDTH / 2 - 12, height: 20)
        pdf.move_down(h + 6)
      end

      def section(pdf, title, rows, sidebar: true)
        rows = rows.reject { |r| r[:text].blank? }
        content_width = sidebar ? WIDTH - SIDEBAR - 10 : WIDTH - 12
        x = sidebar ? SIDEBAR + 10 : 6
        content_h = rows.sum { |r| pdf.height_of(r[:text], width: content_width - (r[:type] == :checkbox ? 18 : 0), size: r[:size] || 8) + 2 }
        label_h = sidebar ? [pdf.height_of(title, width: SIDEBAR - 12, size: 9) + 12, 32].max : 0
        block_h = [label_h, content_h + 16].max
        ensure_space(pdf, block_h + 4)
        y = pdf.cursor

        pdf.line_width(1.2)
        pdf.stroke_horizontal_line(0, WIDTH, at: y)

        if sidebar
          pdf.fill_color(GREY)
          pdf.fill_rectangle([0, y], SIDEBAR, label_h)
          pdf.fill_color("000000")
          pdf.font("Helvetica-Bold")
          pdf.font_size(9)
          pdf.text_box(title, at: [6, y - 6], width: SIDEBAR - 12, height: label_h)
        end

        pdf.bounding_box([x, y - 8], width: content_width, height: content_h) do
          rows.each do |r|
            pdf.font(r[:style] == :bold ? "Helvetica-Bold" : "Helvetica")
            pdf.font_size(r[:size] || 8)
            if r[:type] == :checkbox
              checked = r[:checked]
              pdf.stroke_rectangle([0, pdf.cursor], 10, 10)
              pdf.draw_text("X", at: [2, pdf.cursor - 8]) if checked
              pdf.bounding_box([16, pdf.cursor], width: content_width - 16) { pdf.text(r[:text], align: :left) }
            else
              pdf.text(r[:text], align: r[:align] || :center)
            end
            pdf.move_down(2)
          end
        end
        pdf.move_cursor_to(y - block_h)
      end

      def add_chrome(pdf, data, start_page, end_page, summary:)
        (start_page..end_page).each do |page|
          pdf.go_to_page(page)
          header(pdf, data, page - start_page + 1, end_page - start_page + 1, summary)
          footer(pdf)
        end
        pdf.go_to_page(end_page)
      end

      def header(pdf, d, page_no, page_count, summary)
        pdf.canvas do
          top = pdf.page.dimensions[3] - 30
          pdf.font("Helvetica-Bold")
          pdf.font_size(8)
          pdf.draw_text("National Practitioner Data Bank", at: [78, top - 7])
          pdf.font("Helvetica")
          pdf.font_size(7)
          ["Health Resources and Services Administration", "U.S. Department of Health and Human Services",
           "P.O. Box 10832", "Chantilly, VA 20153-0832", "https://www.npdb.hrsa.gov"].each_with_index do |line, i|
            pdf.draw_text(line, at: [78, top - 18 - i * 11])
          end

          pdf.stroke_rectangle([366, top], 210, 88)
          dcn = summary ? d[:dcn] : d[:report_dcn].presence || d[:dcn]
          date = summary ? d[:process_date] : d[:report_process_date].presence || d[:process_date]
          lines = ["DCN: #{safe(dcn)}", "Process Date: #{safe(date)}", "Page: #{page_no} of #{page_count}",
                   subject_name(d), "For authorized use by:", safe(d[:authorized_org_name].presence || d[:entity_name])]
          lines.each_with_index { |line, i| pdf.draw_text(line, at: [373, top - 12 - i * 11]) }
          pdf.line_width(2)
          pdf.stroke_horizontal_line(36, 576, at: top - 96)
        end
      end

      def footer(pdf)
        pdf.canvas do
          text = "CONFIDENTIAL DOCUMENT - FOR AUTHORIZED USE ONLY"
          pdf.font("Helvetica-Bold")
          pdf.font_size(9)
          pdf.draw_text(text, at: [(612 - pdf.width_of(text, size: 9)) / 2, 12])
        end
      end

      def add_watermark(pdf, text)
        pdf.number_pages(text, at: [130, 360], size: 70, rotate: 45, color: "D0D0D0", opacity: 0.25)
      end

      def render_errors(pdf, errors)
        pdf.start_new_page
        pdf.font("Helvetica-Bold")
        pdf.text("NPDB RESPONSE ERROR", align: :center)
        pdf.move_down(12)
        errors.each { |e| pdf.text(e.to_s) }
      end

      def summary_heading(pdf, title, note = nil)
        h = note ? 18 : 14
        pdf.fill_color(GREY)
        pdf.fill_rectangle([0, pdf.cursor], WIDTH, h)
        pdf.fill_color("000000")
        pdf.font("Helvetica-Bold")
        pdf.font_size(9)
        pdf.text_box(note ? "#{title} (#{note})" : title, at: [4, pdf.cursor - 2], width: WIDTH - 8, height: h)
        pdf.move_down(h + 4)
      end

      def summary_rows(pdf, rows)
        rows.each do |label, value|
          pdf.font("Helvetica-Bold")
          pdf.text_box(label, at: [14, pdf.cursor], width: 145, height: 14)
          pdf.font("Helvetica")
          pdf.text_box(safe(value), at: [160, pdf.cursor], width: 360, height: 26)
          pdf.move_down(13)
        end
      end

      def pair_rows(rows)
        rows.map { |label, value| { text: "#{label} #{safe(value)}".strip, align: :center } }
      end

      def rich_rows(items)
        bold = false
        items.each_with_object([]) do |item, result|
          if item == :bold
            bold = true
          else
            result << { text: item, style: bold ? :bold : nil, align: :center }
            bold = false
          end
        end
      end

      def checkbox(text, checked)
        { text: text, type: :checkbox, checked: ActiveModel::Type::Boolean.new.cast(checked), align: :left }
      end

      def lookup(method, code)
        return "" if safe(code).blank?
        service = Webscraper::NpdbCodeLookup
        return safe(code) unless service.respond_to?(method)
        label = service.public_send(method, code)
        service.display(code, label)
      end

      def normalized_type(report)
        value = report[:category].presence || report[:type].presence || report[:report_type]
        value.to_s.downcase.gsub(/[^a-z0-9]+/, "_").to_sym
      end

      def report_title(type)
        SUMMARY_TYPES.to_h.fetch(type, type.to_s.tr("_", " ").upcase)
      end

      def query_title(data)
        data[:root_name].to_s == "pdsResponse" ? "CONTINUOUS QUERY RESPONSE" : "ONE-TIME QUERY RESPONSE"
      end

      def query_type(data)
        data[:root_name].to_s == "pdsResponse" ?
          "This is a Continuous Query response." :
          "This is a One-Time query response. Your organization will only receive future reports on this practitioner if another query is submitted."
      end

      def statutes(d)
        values = []
        values << "Title IV" if d[:title_iv] || d.dig(:processed_under, :title_iv)
        values << "Section 1921" if d[:section_1921] || d.dig(:processed_under, :section_1921)
        values << "Section 1128E" if d[:section_1128e] || d.dig(:processed_under, :section_1128e)
        values.presence&.join("; ") || "Title IV; Section 1921; Section 1128E"
      end

      def authorized_submitter(d)
        [d[:certification_name], d[:certification_title], phone(d[:certification_phone])].reject(&:blank?).join(", ")
      end

      def entity_name(d)
        safe(d[:latest_contact_entity_name].presence || d[:entity_name].presence || d[:authorized_org_name])
      end

      def summary_action(r)
        type = normalized_type(r)
        type == :mmpr ? lookup(:mmpr_payment_result, r[:payment_result_of_code].presence || r[:payment_result_of]) :
                        lookup(:aar_action, r[:action_code].presence || r[:action])
      end

      def summary_basis(r)
        type = normalized_type(r)
        type == :mmpr ? lookup(:mmpr_specific_allegation, r[:specific_allegation_code].presence || r[:specific_allegation]) :
                        lookup(:aar_basis, r[:basis_code])
      end

      def subject_name(d)
        last = safe(d[:subject_last])
        rest = [safe(d[:subject_first]), safe(d[:subject_middle])].reject(&:blank?).join(" ")
        rest.present? ? "#{last}, #{rest}" : last
      end

      def occupation(d)
        label = lookup(:occupation, d[:occupation_field])
        [label, d[:occupation_state].present? ? "State #{d[:occupation_state]}" : nil].compact.join(" ")
      end

      def license_line(d)
        return "NO LICENSE, #{safe(d[:occupation_state])}" if d[:no_license]
        [safe(d[:license_number]), safe(d[:occupation_state])].reject(&:blank?).join(", ")
      end

      def license_summary(d)
        [lookup(:occupation, d[:occupation_field]), safe(d[:license_number]), safe(d[:occupation_state])].reject(&:blank?).join(", ")
      end

      def statute(code)
        lookup(:statutory_authority, code)
      end

      def patient_age(d)
        age = safe(d[:patient_age])
        return age if age.blank? || age.upcase == "UNKNOWN" || age.include?("YEAR")
        "#{age} YEARS"
      end

      def address(street, city, state, zip)
        [safe(street), city_state_zip(city, state, zip)].reject(&:blank?).join(", ")
      end

      def city_state_zip(city, state, zip)
        [[safe(city), safe(state)].reject(&:blank?).join(", "), safe(zip)].reject(&:blank?).join(" ")
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
        return "" if safe(value).blank?
        number = value.to_s.gsub(/[^\d.\-]/, "").to_f
        "$ #{format('%.2f', number).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      end

      def center_rule(pdf, text)
        pdf.font("Helvetica-Bold")
        pdf.font_size(13)
        tw = pdf.width_of(text, size: 13)
        y = pdf.cursor
        left_end = (WIDTH - tw) / 2 - 12
        right_start = (WIDTH + tw) / 2 + 12
        pdf.stroke_horizontal_line(42, left_end, at: y)
        pdf.stroke_horizontal_line(right_start, WIDTH - 42, at: y)
        pdf.draw_text(text, at: [(WIDTH - tw) / 2, y - 4])
      end

      def end_report(pdf)
        pdf.move_down(10)
        center_rule(pdf, "END OF REPORT")
      end

      def ensure_space(pdf, height)
        pdf.start_new_page if pdf.cursor < height
      end

      def safe(value)
        value.to_s.strip
      end

      def apply_provider_fallbacks!(data, ppi)
        data[:subject_last] = ppi.last_name.to_s.upcase.presence || data[:subject_last]
        data[:subject_first] = ppi.first_name.to_s.upcase.presence || data[:subject_first]
        data[:subject_middle] = ppi.middle_name.to_s.upcase.presence || data[:subject_middle]
        data[:npi] = ppi.npi.to_s.presence || data[:npi] if ppi.respond_to?(:npi)
        data[:ssn] = mask_ssn(ppi.ssn.to_s).presence || data[:ssn] if ppi.respond_to?(:ssn)
      end
    end
  end
end

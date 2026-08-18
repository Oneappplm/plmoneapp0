# frozen_string_literal: true

require "prawn"
require "fileutils"

module Webscraper
  class NpdbMmprPdfRenderer
    PAGE_SIZE = "LETTER"

    LEFT_MARGIN   = 36
    RIGHT_MARGIN  = 36
    BOTTOM_MARGIN = 24
    TOP_MARGIN    = 118

    # Page 1 layout tuning only. Data/parser behavior is unchanged.
    SUMMARY_LEFT_X = 25
    SUMMARY_VALUE_X = 138

    CONTENT_WIDTH = 540
    SIDEBAR_W     = 106
    RIGHT_COL_X   = SIDEBAR_W + 8
    RIGHT_COL_W   = CONTENT_WIDTH - RIGHT_COL_X

    GREY_SECTION = "CFCFCF"
    GREY_LIGHT   = "EEEEEE"
    GREY_MID     = "D9D9D9"

    SECTION_FONT_SIZE = 8.5
    SECTION_LINE_GAP  = 1.5

    def self.render_to_file!(
      output_path:,
      response_xml:,
      provider_personal_information:,
      watermark: "",
      errors: []
    )
      FileUtils.mkdir_p(File.dirname(output_path))
      FileUtils.rm_f(output_path)

      data = Webscraper::NpdbMmprXmlParser.new(response_xml).to_h

      # Preserve the existing behavior of allowing the local provider record to
      # supply query-level identifying values when they are available.
      apply_provider_overrides!(data, provider_personal_information)

      Prawn::Document.generate(
        output_path.to_s,
        page_size: PAGE_SIZE,
        margin: [TOP_MARGIN, RIGHT_MARGIN, BOTTOM_MARGIN, LEFT_MARGIN]
      ) do |pdf|
        pdf.font("Helvetica")
        pdf.font_size 9

        pdf.repeat(:all, dynamic: true) do
          header(pdf, data)
          footer(pdf)
        end

        render_query_summary(pdf, data)

        pdf.start_new_page

        render_unabridged_report(pdf, data)

        render_watermark(pdf, watermark) if watermark.to_s.present?
        render_errors(pdf, errors) if Array(errors).present?
      end

      output_path
    end

    # =========================================================
    # SUMMARY PAGE
    # =========================================================

    def self.render_query_summary(pdf, d)
      # Page 1 only: compact spacing and proportions to match the official NPDB output.
      pdf.font("Helvetica-Bold")
      pdf.font_size 14
      pdf.text(
        "#{query_subject_name(d)} - ONE-TIME QUERY RESPONSE",
        align: :left
      )
      pdf.move_down 4

      summary_band(
        pdf,
        "A. SUBJECT IDENTIFICATION INFORMATION",
        "(Recipients should verify that subject identified is, in fact, the subject of interest.)"
      )

      summary_two_column_rows(
        pdf,
        [
          ["Practitioner Name:", query_subject_name(d)],
          ["Date of Birth:", d[:query_birthdate]],
          ["Work Address:", full_address(d[:query_work_addr1], d[:query_work_addr2], d[:query_work_city], d[:query_work_state], d[:query_work_zip])],
          ["Home Address:", full_address(
            d[:query_home_addr1].presence || d[:query_work_addr1],
            d[:query_home_addr2].presence || d[:query_work_addr2],
            d[:query_home_city].presence || d[:query_work_city],
            d[:query_home_state].presence || d[:query_work_state],
            d[:query_home_zip].presence || d[:query_work_zip]
          )],
          ["Social Security Number:", mask_ssn(d[:query_ssn])],
          ["License:", query_license_line(d)]
        ],
        side_pair: ["Sex:", d[:query_sex]]
      )

      pdf.move_down 3
      summary_band(pdf, "B. QUERY INFORMATION")

      summary_rows(
        pdf,
        [
          ["Statutes Queried:", statutes_queried(d)],
          ["Query Type:", "This is a One-Time query response. Your organization will only receive\nfuture reports on this practitioner if another query is submitted."],
          ["Entity Name:", authorized_org_display(d)],
          ["Authorized Agent:", authorized_agent_display(d)],
          ["Authorized Submitter:", authorized_submitter_display(d)]
        ]
      )

      pdf.move_down 3
      summary_band(
        pdf,
        "C. SUMMARY OF REPORTS ON FILE WITH THE NPDB AS OF #{safe(d[:process_date])}"
      )

      render_report_search_summary(pdf, d)
      pdf.move_down 9
      render_summary_finding_card(pdf, d)
      pdf.move_down 26

      pdf.font("Helvetica-Bold")
      pdf.font_size 13
      pdf.text(
        "--------------------------  Unabridged Report(s) Follow  --------------------------",
        align: :center
      )
    end

    def self.summary_band(pdf, title, note = nil)
      y = pdf.cursor
      h = 14

      pdf.save_graphics_state
      pdf.fill_color GREY_SECTION
      pdf.fill_rounded_rectangle([0, y], CONTENT_WIDTH, h, 5)
      pdf.restore_graphics_state

      pdf.font("Helvetica-Bold")
      pdf.font_size 9.2

      if note.present?
        title_w = 292
        pdf.text_box(
          title.to_s,
          at: [2, y - 1],
          width: title_w,
          height: h - 1,
          valign: :center
        )

        pdf.font("Helvetica")
        pdf.font_size 7.6
        pdf.text_box(
          note.to_s,
          at: [title_w, y - 1],
          width: CONTENT_WIDTH - title_w - 3,
          height: h - 1,
          valign: :center
        )
      else
        pdf.text_box(
          title.to_s,
          at: [2, y - 1],
          width: CONTENT_WIDTH - 4,
          height: h - 1,
          valign: :center
        )
      end

      pdf.move_down h + 1
    end

    def self.summary_rows(pdf, pairs)
      label_w = 112
      value_w = CONTENT_WIDTH - SUMMARY_VALUE_X - 5

      pairs.each do |label, value|
        next if value.blank?

        value_text = value.to_s
        h = if label.to_s == "Query Type:"
              24
            else
              [
                pdf.height_of(label.to_s, width: label_w, size: 8.2),
                pdf.height_of(value_text, width: value_w, size: 8.2)
              ].max + 1
            end

        pdf.bounding_box([SUMMARY_LEFT_X, pdf.cursor], width: CONTENT_WIDTH - SUMMARY_LEFT_X, height: h) do
          pdf.font("Helvetica-Bold")
          pdf.font_size 8.2
          pdf.text_box(label.to_s, at: [0, h], width: label_w, height: h)

          pdf.font("Courier")
          pdf.font_size 8.2
          pdf.text_box(value_text, at: [SUMMARY_VALUE_X - SUMMARY_LEFT_X, h], width: value_w, height: h)
        end

        pdf.move_down h
      end
    ensure
      pdf.font("Helvetica")
    end

    def self.summary_two_column_rows(pdf, pairs, side_pair:)
      label_w = 112
      value_w = 285
      right_label_x = 392
      right_value_x = 446

      pairs.each_with_index do |(label, value), index|
        h = 11.5

        pdf.bounding_box([SUMMARY_LEFT_X, pdf.cursor], width: CONTENT_WIDTH - SUMMARY_LEFT_X, height: h) do
          pdf.font("Helvetica-Bold")
          pdf.font_size 8.2
          pdf.text_box(label.to_s, at: [0, h], width: label_w, height: h)

          pdf.font("Courier")
          pdf.font_size 8.2
          pdf.text_box(value.to_s, at: [SUMMARY_VALUE_X - SUMMARY_LEFT_X, h], width: value_w, height: h)

          if index == 1 && side_pair
            pdf.font("Helvetica-Bold")
            pdf.text_box(side_pair[0].to_s, at: [right_label_x - SUMMARY_LEFT_X, h], width: 48, height: h)
            pdf.font("Courier")
            pdf.text_box(side_pair[1].to_s.upcase, at: [right_value_x - SUMMARY_LEFT_X, h], width: 80, height: h)
          end
        end

        pdf.move_down h
      end
    ensure
      pdf.font("Helvetica")
    end

    def self.render_report_search_summary(pdf, _d)
      left = [
        ["Medical Malpractice Payment Report", "Yes, See Below"],
        ["State Licensure or Certification Action", "No Reports"],
        ["Exclusion or Debarment Action(s):", "No Reports"],
        ["Government Administrative Action(s):", "No Reports"],
        ["Clinical Privileges Action(s):", "No Reports"]
      ]

      right = [
        ["Health Plan Action(s):", "No Reports"],
        ["Professional Society Action(s):", "No Reports"],
        ["DEA/Federal Licensure Action(s):", "No Reports"],
        ["Judgment or Conviction Report(s):", "No Reports"],
        ["Peer Review Organization Action(s):", "No Reports"]
      ]

      box_h = 66
      y = pdf.cursor

      pdf.stroke_rounded_rectangle([14, y], CONTENT_WIDTH - 28, box_h, 5)

      pdf.font("Helvetica-Bold")
      pdf.font_size 8.2
      pdf.text_box(
        "The following report types have been searched:",
        at: [20, y - 5],
        width: CONTENT_WIDTH - 40,
        height: 10
      )

      render_summary_status_column(pdf, left, x: 28, y: y - 19, width: 246)
      render_summary_status_column(pdf, right, x: 292, y: y - 19, width: 222)

      pdf.move_down box_h + 1
    end

    def self.render_summary_status_column(pdf, rows, x:, y:, width:)
      label_w = width - 74

      rows.each_with_index do |(label, status), index|
        row_y = y - (index * 10)

        pdf.font("Helvetica")
        pdf.font_size 7.8
        pdf.text_box(label, at: [x, row_y], width: label_w, height: 10)

        pdf.font(status.start_with?("Yes") ? "Helvetica-Bold" : "Helvetica")
        pdf.text_box(status, at: [x + label_w, row_y], width: 74, height: 10)
      end
    end

    def self.render_summary_finding_card(pdf, d)
      y = pdf.cursor
      h = 66

      pdf.stroke_rounded_rectangle([14, y], CONTENT_WIDTH - 28, h, 5)

      pdf.save_graphics_state
      pdf.fill_color GREY_LIGHT
      pdf.fill_rectangle([15, y - 1], CONTENT_WIDTH - 30, 39)
      pdf.restore_graphics_state

      entity = d[:entity_name].presence || d[:latest_contact_entity_name]

      pdf.font("Helvetica-Bold")
      pdf.font_size 10.4
      pdf.text_box(entity.to_s.upcase, at: [20, y - 5], width: CONTENT_WIDTH - 40, height: 12)

      pdf.font_size 8.6
      pdf.text_box(
        "MEDICAL MALPRACTICE PAYMENT",
        at: [20, y - 19],
        width: CONTENT_WIDTH - 40,
        height: 11
      )

      pdf.font("Helvetica-Bold")
      pdf.font_size 8
      pdf.text_box("Basis for Action:", at: [20, y - 30], width: 88, height: 10)
      pdf.font("Helvetica")
      pdf.text_box(
        "- #{strip_code(d[:specific_allegation]).to_s.upcase}",
        at: [108, y - 30],
        width: 245,
        height: 10
      )

      pdf.font("Helvetica-Bold")
      pdf.text_box("Initial Action:", at: [22, y - 43], width: 86, height: 10)
      pdf.font("Helvetica")
      pdf.text_box(
        "- #{strip_code(d[:payment_result_of]).to_s.upcase}",
        at: [108, y - 43],
        width: 180,
        height: 10
      )

      pdf.font("Helvetica-Bold")
      pdf.text_box("Date of Action:", at: [390, y - 43], width: 78, height: 10)
      pdf.font("Helvetica")
      pdf.text_box(safe(d[:date_this_payment]), at: [468, y - 43], width: 55, height: 10)

      pdf.font("Helvetica-Bold")
      pdf.text_box("DCN:", at: [22, y - 54], width: 42, height: 9)
      pdf.font("Courier")
      pdf.text_box(safe(d[:report_dcn]), at: [108, y - 54], width: 160, height: 9)

      pdf.move_down h + 1
    end

    def self.render_unabridged_report(pdf, d)
      pdf.font("Helvetica-Bold")
      pdf.font_size 15
      pdf.text(report_subject_name(d), align: :center)
      pdf.move_down 6

      report_header_block(pdf, d)
      pdf.move_down 6

      render_reporting_entity(pdf, d)
      render_report_subject(pdf, d)

      rows = information_reported_rows(d)
      section_sidebar_block_rich(pdf, "C. INFORMATION\nREPORTED", rows)

      rows_d = subject_statement_rows(d)
      section_sidebar_block_rich(pdf, "D. SUBJECT\nSTATEMENT", rows_d)

      # The official Powell report carries status over the final two pages.
      rows_e = report_status_rows(d)
      section_sidebar_block_rich(pdf, "E. REPORT\nSTATUS", rows_e)

      supplemental_rows = supplemental_subject_rows(d)
      if supplemental_rows.present?
        section_sidebar_block_rich(
          pdf,
          "F. SUPPLEMENTAL\nSUBJECT\nINFORMATION ON\nFILE WITH DATA\nBANK",
          supplemental_rows
        )
      end

      render_maintained_under(pdf, d)
      draw_end_of_report(pdf)
    end

    def self.render_reporting_entity(pdf, d)
      entity_name = safe(d[:entity_name])
      entity_name += " *" if d[:latest_contact_present]

      rows = [
        ["Entity Name:", entity_name],
        ["Address:", join_nonblank(d[:entity_addr1], d[:entity_addr2])],
        ["City, State, Zip:", city_state_zip(d[:entity_city], d[:entity_state], d[:entity_zip])],
        ["Country:", d[:entity_country]],
        ["Name or Office:", d[:entity_office]],
        ["Title or Department:", d[:entity_title]],
        ["Telephone:", phone(d[:entity_phone])],
        ["Entity Internal Report Reference:", d[:entity_internal_ref]],
        ["Type of Report:", d[:transaction]]
      ]

      rows << ["Previous Report Number:", previous_report(d[:previous_dcn])] if d[:previous_dcn].present?

      section_sidebar_block(pdf, "A. REPORTING\nENTITY", rows)

      return unless d[:latest_contact_present]

      rich = [
        {
          text: "*The reporting entity has changed its name or address on file with the NPDB. The following is the entity's most recent contact information reported to the NPDB on #{safe(d[:latest_contact_last_update_date])}:",
          size: 8,
          align: :left
        },
        { text: "Entity Name: #{safe(d[:latest_contact_entity_name])}", align: :center },
        { text: "Address: #{join_nonblank(d[:latest_contact_addr1], d[:latest_contact_addr2])}", align: :center },
        {
          text: "City, State, Zip: #{city_state_zip(d[:latest_contact_city], d[:latest_contact_state], d[:latest_contact_zip])}",
          align: :center
        },
        { text: "Country: #{safe(d[:latest_contact_country])}", align: :center }
      ]

      section_sidebar_block_rich(pdf, "", rich, draw_top_rule: false, sidebar_fill: false)
    end

    def self.render_report_subject(pdf, d)
      rows = [
        ["Subject Name:", report_subject_name(d)],
        ["Other Name(s) Used:", Array(d[:other_names]).join("; ")],
        ["Sex:", d[:sex]],
        ["Date of Birth:", d[:birthdate]],
        ["Organization Name:", d[:org_name]],
        ["Work Address:", join_nonblank(d[:work_addr1], d[:work_addr2])],
        ["City, State, ZIP:", city_state_zip(d[:work_city], d[:work_state], d[:work_zip])],
        ["Home Address:", join_nonblank(d[:home_addr1], d[:home_addr2])],
        ["City, State, ZIP:", city_state_zip(d[:home_city], d[:home_state], d[:home_zip])],
        ["Deceased:", d[:deceased]],
        ["Social Security Numbers (SSN):", d[:ssn]],
        ["National Provider Identifiers (NPI):", d[:npi]],
        ["Professional School(s) & Year(s) of Graduation:", d[:professional_school]],
        ["Occupation/Field of Licensure:", d[:occupation_field]],
        ["State License Number, State of Licensure:", report_license_line(d)],
        ["Drug Enforcement Administration (DEA) Numbers:", ""],
        ["Hospital Affiliation(s):", d[:hospital_affiliations]]
      ]

      section_sidebar_block(
        pdf,
        "B. SUBJECT\nIDENTIFICATION\nINFORMATION\n(INDIVIDUAL)",
        rows
      )
    end

    def self.information_reported_rows(d)
      [
        { text: "Date of Report: #{safe(d[:report_process_date].presence || d[:original_submission_date])}" },
        { text: "Relationship of Entity to\nThis Practitioner: #{safe(d[:relationship])}" },

        { text: "PAYMENTS BY THIS PAYER FOR THIS PRACTITIONER", style: :bold },
        { text: "Amount of This Payment\nfor This Practitioner: #{safe(d[:amount_this_payment])}" },
        { text: "Date of This Payment: #{safe(d[:date_this_payment])}" },
        { text: "This Payment Represents: #{safe(d[:payment_type])}" },
        { text: "Total Amount Paid or to Be Paid by\nThis Payer for This Practitioner: #{safe(d[:total_paid])}" },
        { text: "Payment Result of: #{safe(d[:payment_result_of])}" },
        { text: "Date of Settlement, if Any: #{safe(d[:judgment_date])}" },
        { text: "Adjudicative Body Case Number: #{safe(d[:adjudicative_body_case_number])}" },
        { text: "Adjudicative Body Name: #{safe(d[:adjudicative_body_name])}" },
        { text: "Court File Number: #{safe(d[:court_file_number])}" },
        {
          text: "Description of Settlement and Any\nConditions, Including Terms of Payment: #{safe(d[:judgment_desc])}"
        },
        {
          text: "Total Number of Claimants Included in The Settlement: #{safe(d[:claimant_count])}"
        },

        { text: "PAYMENTS BY THIS PAYER FOR OTHER PRACTITIONERS IN THIS CASE", style: :bold },
        {
          text: "Total Amount Paid or to Be Paid by This Payer for All\nPractitioners in This Case: #{safe(d[:other_practitioners_total])}"
        },
        {
          text: "Number of Practitioners for Whom This Payer Has Paid\nor Will Pay in This Case: #{safe(d[:other_practitioners_count])}"
        },

        { text: "PAYMENTS BY OTHERS FOR THIS PRACTITIONER", style: :bold },
        {
          text: "Did (or will) a State Guaranty or Excess Fund\nMake a Payment for This Practitioner in This Case?: #{safe(d[:state_fund_payment])}"
        },
        {
          text: "Amount Paid or Expected to Be Paid by the State Fund: #{safe(d[:state_fund_amount])}"
        },
        {
          text: "Did (or will) a Self-Insured Organization and/or Other Insurance\nCompany Make a Payment for This Practitioner in This Case?: #{safe(d[:self_insured_payment])}"
        },
        {
          text: "Amount Paid or Expected to Be Paid by Self-Insured\nOrganization(s) and/or Other Insurance Company/Companies: #{safe(d[:self_insured_amount])}"
        },

        { text: "CLASSIFICATION OF ACT(S) OR OMISSION(S)", style: :bold },
        { text: "Patient's Age at Time of Initial Event: #{safe(d[:patient_age])}" },
        { text: "Patient's Sex: #{safe(d[:patient_sex])}" },
        { text: "Patient's Type: #{safe(d[:patient_type])}" },
        {
          text: "Description of the Medical Condition With Which the Patient\nPresented for Treatment: #{safe(d[:medical_condition_desc])}"
        },
        { text: "Description of the Procedure Performed: #{safe(d[:procedure_desc])}" },
        { text: "Nature of Allegation: #{safe(d[:nature_allegation])}" },
        { text: "Specific Allegation: #{safe(d[:specific_allegation])}" },
        {
          text: "Date of Event Associated With Allegation or Incident: #{safe(d[:event_date])}"
        },
        { text: "Outcome: #{safe(d[:outcome])}" },
        {
          text: "Description of the Allegations and Injuries or Illnesses Upon\nWhich the Action or Claim Was Based: #{safe(d[:allegations_desc])}"
        }
      ]
    end

    def self.subject_statement_rows(d)
      rows = [
        {
          text: "If the subject identified in Section B of this report has submitted a statement, it appears in this section.",
          size: 8,
          align: :left
        }
      ]

      if d[:dispute_status].present?
        rows << { text: safe(d[:dispute_status]), size: 8, align: :left }
      end

      rows
    end

    def self.report_status_rows(d)
      first_checked = safe(d[:report_disputed_mark]).present?
      third_checked = safe(d[:report_reviewed_reconsidered_mark]).present?

      [
        {
          text: "Unless a box below is checked, the subject of this report identified in Section B has not contested this report.",
          size: 8,
          align: :left
        },
        {
          type: :checkbox,
          box: first_checked ? :x : :empty,
          text: "This report has been disputed by the subject identified in Section B.",
          size: 8
        },
        {
          type: :checkbox,
          box: :empty,
          text: "At the request of the subject identified in Section B, this report is being reviewed by the Secretary of the U.S. Department of Health and Human Services to determine its accuracy and/or whether it complies with reporting requirements. No decision has been reached.",
          size: 8
        },
        {
          type: :checkbox,
          box: third_checked ? :x : :empty,
          text: "At the request of the subject identified in Section B, this report was reviewed by the Secretary of the U.S. Department of Health and Human Services and a decision was reached. The subject has requested that the Secretary reconsider the original decision.",
          size: 8
        },
        {
          type: :checkbox,
          box: :empty,
          text: "At the request of the subject identified in Section B, this report was reviewed by the Secretary of the U.S. Department of Health and Human Services. The Secretary's decision is shown below:",
          size: 8
        },
        {
          text: "Date of Original Submission: #{safe(d[:original_submission_date])}",
          size: 8,
          align: :left
        },
        {
          text: "Date of Most Recent Change: #{safe(d[:most_recent_change_date])}",
          size: 8,
          align: :left
        }
      ]
    end

    def self.supplemental_subject_rows(d)
      rows = []

      Array(d[:supplemental_ssns]).each do |ssn|
        rows << { text: "Social Security Numbers (SSN): #{ssn}", align: :center }
      end

      Array(d[:supplemental_npis]).each do |npi|
        rows << { text: "National Provider Identifiers (NPI): #{npi}", align: :center }
      end

      Array(d[:supplemental_licenses]).each do |license|
        rows << {
          text: "Occupation/Field of Licensure: #{safe(license[:occupation])}",
          align: :center
        }
        rows << {
          text: "State License Number, State of Licensure: #{safe(license[:number])}, #{safe(license[:state])}",
          align: :center
        }
      end

      Array(d[:supplemental_dea_numbers]).each do |dea|
        rows << {
          text: "Drug Enforcement Administration (DEA) Numbers: #{dea}",
          align: :center
        }
      end

      if d[:supplemental_disclaimer].present?
        rows << { text: "", size: 4, align: :left }
        rows << {
          text: "The following information was not provided by the reporting entity identified in Section A of this report. The information was submitted to the Data Bank from other sources and is intended to supplement the information contained in this report.",
          size: 7.5,
          align: :left
        }
      end

      rows
    end

    def self.render_maintained_under(pdf, d)
      ensure_space!(pdf, 82)

      y = pdf.cursor
      pdf.line_width = 1
      pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: y)
      pdf.move_down 8

      pdf.font("Helvetica-Bold")
      pdf.font_size 8.5
      pdf.text(
        "This report is maintained under the provisions of: Title #{safe(d[:maintained_under])}".strip,
        align: :left
      )

      pdf.move_down 6
      pdf.font("Helvetica")
      pdf.font_size 7.5
      pdf.text(
        "The information contained in this report is maintained by the National Practitioner Data Bank for restricted use under the provisions of Title IV of Public Law 99-660, as amended, and 45 CFR Part 60. All information is confidential and may be used only for the purpose for which it was disclosed. Disclosure or use of confidential information for other purposes is a violation of federal law. For additional information or clarification, contact the reporting entity identified in Section A.",
        align: :left
      )
    end

    # =========================================================
    # HEADER / FOOTER
    # =========================================================

    def self.header(pdf, d)
      pdf.canvas do
        page_top = pdf.page.dimensions[3] - 20

        draw_npdb_identity(pdf, page_top)

        right_x = 388
        box_w = 180
        box_h = 82

        pdf.stroke_rectangle([right_x, page_top], box_w, box_h)

        if pdf.page_number == 1
          header_dcn = d[:dcn]
          header_date = d[:process_date]
          page_text = "1 of 1"
          name = query_subject_name(d)
        else
          header_dcn = d[:report_dcn].presence || d[:dcn]
          header_date = d[:report_process_date].presence || d[:original_submission_date]
          report_page = pdf.page_number - 1
          report_count = [pdf.page_count - 1, 1].max
          page_text = "#{report_page} of #{report_count}"
          name = report_subject_name(d)
        end

        y = page_top - 11

        pdf.font("Helvetica-Bold")
        pdf.font_size 8.4
        pdf.draw_text("DCN:", at: [right_x + 6, y])
        pdf.font("Courier")
        pdf.draw_text(safe(header_dcn), at: [right_x + 38, y])

        y -= 12
        pdf.font("Helvetica")
        pdf.draw_text("Process Date:", at: [right_x + 6, y])
        pdf.font("Courier")
        pdf.draw_text(safe(header_date), at: [right_x + 70, y])

        y -= 12
        pdf.font("Helvetica")
        pdf.draw_text("Page:", at: [right_x + 6, y])
        pdf.font("Courier")
        pdf.draw_text(page_text, at: [right_x + 38, y])

        y -= 12
        pdf.font("Courier")
        pdf.draw_text(name, at: [right_x + 6, y])

        y -= 12
        pdf.font("Helvetica")
        pdf.draw_text("For authorized use by:", at: [right_x + 6, y])

        y -= 12
        pdf.font("Courier")
        pdf.font_size 8.2
        pdf.draw_text(authorized_org_display(d), at: [right_x + 6, y])

        rule_y = page_top - 87
        pdf.line_width = 2
        pdf.stroke_horizontal_line(LEFT_MARGIN, pdf.page.dimensions[2] - RIGHT_MARGIN, at: rule_y)
        pdf.line_width = 1
      end
    end

    def self.draw_npdb_identity(pdf, page_top)
      left_x = LEFT_MARGIN

      # Text-only NPDB mark; no external image dependency is introduced.
      pdf.font("Helvetica-Bold")
      pdf.font_size 18
      pdf.draw_text("NPDB", at: [left_x + 1, page_top - 40])

      pdf.font("Helvetica")
      pdf.font_size 7.5
      text_x = left_x + 55
      pdf.draw_text("National Practitioner Data Bank", at: [text_x, page_top - 8])
      pdf.draw_text("Health Resources and Services Administration", at: [text_x, page_top - 20])
      pdf.draw_text("U.S. Department of Health and Human Services", at: [text_x, page_top - 32])
      pdf.draw_text("P.O. Box 10832", at: [text_x, page_top - 44])
      pdf.draw_text("Chantilly, VA 20153-0832", at: [text_x, page_top - 56])
      pdf.draw_text("https://www.npdb.hrsa.gov", at: [text_x, page_top - 68])
    end

    def self.footer(pdf)
      pdf.canvas do
        text = "CONFIDENTIAL DOCUMENT - FOR AUTHORIZED USE ONLY"

        pdf.font("Helvetica-Bold")
        pdf.font_size 9

        text_width = pdf.width_of(text, size: 9)
        x = (pdf.page.dimensions[2] - text_width) / 2.0
        y = 15

        pdf.draw_text(text, at: [x, y])
      end
    end

    # =========================================================
    # REPORT HEADER
    # =========================================================

    def self.report_header_block(pdf, d)
      entity = d[:latest_contact_entity_name].presence || d[:entity_name]
      report_title =
        if d[:transaction_code].to_s.upcase == "C"
          "CORRECTION TO MEDICAL MALPRACTICE PAYMENT REPORT"
        else
          "MEDICAL MALPRACTICE PAYMENT REPORT"
        end

      org_h = 24
      title_h = 28
      head_h = 21
      value_h = 22
      total_h = org_h + title_h + head_h + value_h
      y_top = pdf.cursor
      mid_x = CONTENT_WIDTH / 2.0

      pdf.bounding_box([0, y_top], width: CONTENT_WIDTH, height: total_h) do
        pdf.stroke_color "B8B8B8"
        pdf.stroke_rectangle([0, total_h], CONTENT_WIDTH, total_h)

        cursor_y = total_h

        pdf.fill_color GREY_LIGHT
        pdf.fill_rectangle([0, cursor_y], CONTENT_WIDTH, org_h)
        pdf.fill_color "000000"
        pdf.font("Helvetica-BoldOblique")
        pdf.font_size 12
        pdf.text_box(
          entity.to_s,
          at: [0, cursor_y],
          width: CONTENT_WIDTH,
          height: org_h,
          align: :center,
          valign: :center
        )

        cursor_y -= org_h

        pdf.fill_color GREY_MID
        pdf.fill_rectangle([0, cursor_y], CONTENT_WIDTH, title_h)
        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 12
        pdf.text_box(
          report_title,
          at: [6, cursor_y],
          width: 350,
          height: title_h,
          valign: :center
        )
        pdf.text_box(
          "Date of Action: #{safe(d[:date_this_payment])}",
          at: [350, cursor_y],
          width: CONTENT_WIDTH - 356,
          height: title_h,
          align: :right,
          valign: :center
        )

        cursor_y -= title_h

        pdf.fill_color GREY_SECTION
        pdf.fill_rectangle([0, cursor_y], CONTENT_WIDTH, head_h)
        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 11
        pdf.text_box("Initial Action", at: [0, cursor_y], width: mid_x, height: head_h, align: :center, valign: :center)
        pdf.text_box("Basis for Initial Action", at: [mid_x, cursor_y], width: mid_x, height: head_h, align: :center, valign: :center)

        cursor_y -= head_h

        pdf.stroke_vertical_line(cursor_y + head_h, cursor_y - value_h, at: mid_x)

        pdf.font("Helvetica")
        pdf.font_size 9
        pdf.text_box(
          "- #{strip_code(d[:payment_result_of])}",
          at: [6, cursor_y - 4],
          width: mid_x - 12,
          height: value_h
        )
        pdf.text_box(
          "- #{strip_code(d[:specific_allegation])}",
          at: [mid_x + 6, cursor_y - 4],
          width: mid_x - 12,
          height: value_h
        )
      end

      pdf.move_down total_h + 2
    end

    # =========================================================
    # GENERIC SECTION BLOCKS
    # =========================================================

    def self.section_sidebar_block(pdf, sidebar_title, pairs)
      rows = pairs.map do |label, value|
        {
          text: "#{label} #{safe(value)}".strip,
          size: SECTION_FONT_SIZE,
          align: :center
        }
      end

      section_sidebar_block_rich(pdf, sidebar_title, rows)
    end

    def self.section_sidebar_block_rich(
      pdf,
      sidebar_title,
      rows,
      draw_top_rule: true,
      sidebar_fill: true
    )
      rows = Array(rows).map do |r|
        {
          text: r[:text].to_s,
          size: (r[:size] || SECTION_FONT_SIZE),
          style: r[:style],
          align: (r[:align] || :center).to_sym,
          type: (r[:type] || :text).to_sym,
          box: (r[:box] || :empty).to_sym,
          box_size: (r[:box_size] || 10).to_f
        }
      end

      sidebar_text_h =
        if sidebar_title.present?
          pdf.height_of(
            sidebar_title,
            width: SIDEBAR_W - 10,
            size: 9,
            leading: 1
          )
        else
          0
        end

      label_h = sidebar_title.present? ? sidebar_text_h + 10 : 0

      content_h = rows.sum do |r|
        if r[:type] == :checkbox
          text_w = RIGHT_COL_W - r[:box_size] - 5
          text_h = pdf.height_of(r[:text], width: text_w, size: r[:size])
          [r[:box_size], text_h].max + SECTION_LINE_GAP
        else
          pdf.height_of(r[:text], width: RIGHT_COL_W, size: r[:size]) + SECTION_LINE_GAP
        end
      end + 10

      block_h = [label_h, content_h].max
      ensure_space!(pdf, [block_h + 4, 110].min)

      start_y = pdf.cursor

      if draw_top_rule
        pdf.line_width = 1.5
        pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: start_y)
        pdf.line_width = 1
      end

      if sidebar_fill && sidebar_title.present?
        pdf.save_graphics_state
        pdf.fill_color GREY_SECTION
        pdf.fill_rectangle([0, start_y], SIDEBAR_W, label_h)
        pdf.restore_graphics_state

        pdf.font("Helvetica-Bold")
        pdf.font_size 9
        pdf.text_box(
          sidebar_title,
          at: [0, start_y - 3],
          width: SIDEBAR_W,
          height: label_h,
          align: :center,
          valign: :top
        )
      end

      content_x = sidebar_fill ? RIGHT_COL_X : 0
      content_w = sidebar_fill ? RIGHT_COL_W : CONTENT_WIDTH

      pdf.bounding_box(
        [content_x, start_y - 6],
        width: content_w
      ) do
        rows.each do |r|
          if r[:type] == :checkbox
            y = pdf.cursor

            pdf.stroke_rectangle([0, y], r[:box_size], r[:box_size])

            if r[:box] == :x
              pdf.font("Helvetica-Bold")
              pdf.font_size(8)
              pdf.draw_text("X", at: [2.4, y - 8])
            end

            pdf.bounding_box(
              [r[:box_size] + 6, y],
              width: content_w - r[:box_size] - 6
            ) do
              pdf.font(r[:style] == :bold ? "Helvetica-Bold" : "Helvetica")
              pdf.font_size(r[:size])
              pdf.text(r[:text], align: :left)
            end
          else
            pdf.font(r[:style] == :bold ? "Helvetica-Bold" : "Helvetica")
            pdf.font_size(r[:size])
            pdf.text(r[:text], align: r[:align])
          end

          pdf.move_down SECTION_LINE_GAP
        end
      end

      pdf.move_down 3
    end

    # =========================================================
    # HELPERS
    # =========================================================

    def self.apply_provider_overrides!(d, ppi)
      return unless ppi

      # Query page can use the local provider record, but unabridged report
      # identity remains XML-driven so the report reflects the NPDB response.
      d[:query_subject_last] = ppi.last_name.to_s.upcase if ppi.respond_to?(:last_name) && ppi.last_name.present?
      d[:query_subject_first] = ppi.first_name.to_s.upcase if ppi.respond_to?(:first_name) && ppi.first_name.present?
      d[:query_subject_middle] = ppi.middle_name.to_s.upcase if ppi.respond_to?(:middle_name) && ppi.middle_name.present?
      d[:query_subject_suffix] = ppi.suffix.to_s.upcase if ppi.respond_to?(:suffix) && ppi.suffix.present?
    end

    def self.query_subject_name(d)
      name_from_parts(
        d[:query_subject_last],
        d[:query_subject_first],
        d[:query_subject_middle]
      )
    end

    def self.report_subject_name(d)
      name_from_parts(
        d[:subject_last],
        d[:subject_first],
        d[:subject_middle]
      )
    end

    def self.name_from_parts(last, first, middle)
      last = safe(last)
      first = safe(first)
      middle = safe(middle)
      rest = [first, middle].reject(&:blank?).join(" ")
      rest.present? ? "#{last}, #{rest}" : last
    end

    def self.query_license_line(d)
      occupation = safe(d[:query_occupation_field])
      number = safe(d[:query_license_number])
      state = safe(d[:query_occupation_state])

      [occupation, number, state].reject(&:blank?).join(", ")
    end

    def self.report_license_line(d)
      return "NO LICENSE, #{safe(d[:occupation_state])}" if d[:no_license]

      [safe(d[:license_number]), safe(d[:occupation_state])].reject(&:blank?).join(", ")
    end

    def self.statutes_queried(d)
      values = []
      values << "Title IV" if d[:title_iv]
      values << "Section 1921" if d[:section_1921]
      values << "Section 1128E" if d[:section_1128e]
      values.join("; ")
    end

    def self.authorized_org_display(d)
      safe(d[:authorized_org_name]).presence ||
        ENV["NPDB_AUTHORIZED_ORG_NAME"].to_s.presence ||
        "AUTHORIZED NPDB ENTITY"
    end

    def self.authorized_agent_display(d)
      safe(d[:authorized_agent_name]).presence ||
        ENV["NPDB_AUTHORIZED_AGENT_NAME"].to_s
    end

    def self.authorized_submitter_display(d)
      safe(d[:authorized_submitter_name]).presence ||
        ENV["NPDB_AUTHORIZED_SUBMITTER_NAME"].to_s.presence ||
        [
          safe(d[:certification_name]),
          safe(d[:certification_title]),
          phone(d[:certification_phone])
        ].reject(&:blank?).join(", ")
    end

    def self.full_address(addr1, addr2, city, state, zip)
      first = join_nonblank(addr1, addr2)
      second = city_state_zip(city, state, zip)
      [first, second].reject(&:blank?).join(", ")
    end

    def self.city_state_zip(city, state, zip)
      locality = [safe(city), safe(state)].reject(&:blank?).join(", ")
      [locality, safe(zip)].reject(&:blank?).join(" ")
    end

    def self.join_nonblank(*values)
      values.map { |v| safe(v) }.reject(&:blank?).join(" ")
    end

    def self.phone(raw)
      digits = raw.to_s.gsub(/\D/, "")
      return "" if digits.blank?
      return "(#{digits[0, 3]}) #{digits[3, 3]}-#{digits[6, 4]}" if digits.length >= 10

      raw.to_s
    end

    def self.mask_ssn(raw)
      digits = raw.to_s.gsub(/\D/, "")
      return raw.to_s if raw.to_s.include?("*")
      return raw.to_s if digits.length < 4

      "***-**-#{digits[-4, 4]}"
    end

    def self.previous_report(dcn)
      value = safe(dcn)
      return "" if value.blank?

      "#{value} (Please destroy all copies of the previous report)"
    end

    def self.strip_code(value)
      value.to_s.sub(/\s+\([A-Z0-9]+\)\s*\z/, "").strip
    end

    def self.safe(value)
      value.to_s.strip
    end

    def self.ensure_space!(pdf, needed_h)
      pdf.start_new_page if pdf.cursor < needed_h
    end

    def self.draw_end_of_report(pdf)
      ensure_space!(pdf, 30)
      pdf.move_down 9

      text = "END OF REPORT"
      size = 9

      pdf.font("Helvetica-Bold")
      pdf.font_size(size)

      y = pdf.cursor
      text_w = pdf.width_of(text, size: size)
      gap = 10
      left_end = (CONTENT_WIDTH - text_w) / 2.0 - gap
      right_start = (CONTENT_WIDTH + text_w) / 2.0 + gap

      pdf.line_width = 1.5
      pdf.stroke_horizontal_line(0, left_end, at: y)
      pdf.stroke_horizontal_line(right_start, CONTENT_WIDTH, at: y)
      pdf.line_width = 1

      pdf.draw_text(text, at: [(CONTENT_WIDTH - text_w) / 2.0, y - 3])
      pdf.move_down 14
    end

    def self.render_watermark(pdf, watermark)
      return if watermark.blank?

      pdf.repeat(:all) do
        pdf.canvas do
          pdf.save_graphics_state
          pdf.fill_color "CCCCCC"
          pdf.transparent(0.25) do
            pdf.rotate(45, origin: [306, 396]) do
              pdf.font("Helvetica-Bold")
              pdf.font_size 50
              pdf.draw_text(watermark.to_s, at: [165, 390])
            end
          end
          pdf.restore_graphics_state
        end
      end
    end

    def self.render_errors(pdf, errors)
      return if Array(errors).blank?

      pdf.start_new_page
      pdf.font("Helvetica-Bold")
      pdf.font_size 12
      pdf.text("NPDB Processing Errors")
      pdf.move_down 8
      pdf.font("Helvetica")
      pdf.font_size 9
      Array(errors).each { |error| pdf.text("- #{error}") }
    end
  end
end

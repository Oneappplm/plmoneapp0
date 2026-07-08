# frozen_string_literal: true

# app/services/webscraper/npdb_mmpr_pdf_renderer.rb
require "prawn"
require "fileutils"

module Webscraper
  class NpdbMmprPdfRenderer
    PAGE_SIZE     = "LETTER"
    LEFT_MARGIN   = 36
    RIGHT_MARGIN  = 36
    BOTTOM_MARGIN = 22

    GREY_SECTION       = "D9D9D9"
    GREY_BAND          = "E6E6E6"
    GREY_BAND_DARK     = "CFCFCF"

    TOP_MARGIN    = LEFT_MARGIN + 110
    CONTENT_WIDTH = 540

    SECTION_PAD_TOP    = 10
    SECTION_PAD_BOT    = 8
    SECTION_LINE_GAP   = 2
    SECTION_FONT_SIZE  = 9
    LINE_GAP           = 2

    SIDEBAR_W    = 120
    RIGHT_COL_X  = SIDEBAR_W + 10
    RIGHT_COL_W  = CONTENT_WIDTH - RIGHT_COL_X

    def self.render_to_file!(output_path:, response_xml:, provider_personal_information:, watermark: "", errors: [])
      FileUtils.mkdir_p(File.dirname(output_path))
      FileUtils.rm_f(output_path)

      data = Webscraper::NpdbMmprXmlParser.new(response_xml).to_h

      data[:subject_last]   = provider_personal_information.last_name.to_s.upcase.presence || data[:subject_last]
      data[:subject_first]  = provider_personal_information.first_name.to_s.upcase.presence || data[:subject_first]
      data[:subject_middle] = provider_personal_information.middle_name.to_s.upcase.presence || data[:subject_middle]
      data[:npi]            = provider_personal_information.respond_to?(:npi) ? provider_personal_information.npi.to_s.presence || data[:npi] : data[:npi]
      data[:ssn]            = provider_personal_information.respond_to?(:ssn) ? provider_personal_information.ssn.to_s.presence || data[:ssn] : data[:ssn]

      reports = data[:reports].presence || []

      Prawn::Document.generate(
        output_path.to_s,
        page_size: PAGE_SIZE,
        margin: [TOP_MARGIN, RIGHT_MARGIN, BOTTOM_MARGIN, LEFT_MARGIN]
      ) do |pdf|
        pdf.font("Helvetica")
        pdf.font_size 9

        if reports.present?
          render_query_summary(pdf, data)

          reports.each_with_index do |report, index|
            pdf.start_new_page

            merged_data =
              data.merge(report).merge(report[:mmpr] || {}).merge(report[:aar] || {})

            pdf.repeat(:all, dynamic: true) { header(pdf, merged_data, pdf.page_number, pdf.page_count) }
            pdf.repeat(:all) { footer(pdf) }

            case report[:type]
            when "AAR"
              render_aar_body(pdf, merged_data)
            else
              render_body(pdf, merged_data)
            end
          end
        else
          pdf.repeat(:all, dynamic: true) { header(pdf, data, pdf.page_number, pdf.page_count) }
          pdf.repeat(:all) { footer(pdf) }

          if data[:type] == "AAR"
            render_aar_body(pdf, data)
          else
            render_body(pdf, data)
          end
        end

        if watermark.present?
          pdf.repeat(:all) do
            pdf.canvas do
              pdf.fill_color "CCCCCC"
              pdf.transparent(0.25) do
                pdf.rotate(45, origin: [300, 400]) do
                  pdf.font("Helvetica-Bold")
                  pdf.font_size 72
                  pdf.draw_text watermark.to_s, at: [160, 300]
                end
              end
              pdf.fill_color "000000"
            end
          end
        end
      end

      output_path
    end

    # ------------------------------------------------------------
    # QUERY SUMMARY PAGE
    # ------------------------------------------------------------
    def self.render_query_summary(pdf, d)
      pdf.font("Helvetica")
      pdf.font_size 9

      pdf.repeat(:all, dynamic: true) { query_summary_header(pdf, d, pdf.page_number, pdf.page_count) }
      pdf.repeat(:all) { footer(pdf) }

      pdf.font("Helvetica-Bold")
      pdf.font_size 12
      pdf.text "#{subject_name(d)} - QUERY RESPONSE", align: :center
      pdf.move_down 14

      section_sidebar_block(
        pdf,
        "A. SUBJECT\nIDENTIFICATION\nINFORMATION",
        [
          ["Practitioner Name:", subject_name(d)],
          ["Date of Birth:", d[:birthdate]],
          ["Sex:", d[:sex]],
          ["Work Address:", address_line(d[:work_addr1], d[:work_city], d[:work_state], d[:work_zip])],
          ["Home Address:", address_line(d[:home_addr1], d[:home_city], d[:home_state], d[:home_zip])],
          ["Social Security Number:", d[:ssn]],
          ["License:", license_line(d[:no_license], d[:occupation_state], d[:license_number])]
        ]
      )

      section_sidebar_block(
        pdf,
        "B. QUERY\nINFORMATION",
        [
          ["Statutes Queried:", statutes_queried(d)],
          ["Query Type:", query_type_text(d)],
          ["Entity DBID:", d[:submitter_entity_dbid]],
          ["Vendor ID:", d[:submitter_vendor_id]],
          ["Authorized Submitter:", [d[:certification_name], d[:certification_title], phone(d[:certification_phone])].reject(&:blank?).join(", ")]
        ]
      )

      summary_rows = []

      if d[:reports].present?
        summary_rows << { text: "The following report types have been searched:", size: 9 }

        d[:reports].each do |report|
          line =
            case report[:type]
            when "MMPR"
              "Medical Malpractice Payment Report: Yes, See Below"
            when "AAR"
              "Adverse Action Report: Yes, See Below"
            else
              "#{report[:type]} Report: Yes, See Below"
            end

          summary_rows << { text: line, size: 9 }
        end

        summary_rows << { text: "", size: 5 }
        summary_rows << { text: "-------------------------- Unabridged Report(s) Follow --------------------------", size: 9, style: :bold, align: :center }
      else
        summary_rows << { text: "No reports were returned in this response.", size: 9 }
      end

      section_sidebar_block_rich(pdf, "C. SUMMARY OF\nREPORTS ON FILE", summary_rows)
    end

    # ------------------------------------------------------------
    # MMPR BODY
    # ------------------------------------------------------------
    def self.render_body(pdf, d)
      if pdf.page_number == 1
        pdf.font("Helvetica-Bold")
        pdf.font_size 12
        pdf.text subject_name(d), align: :center
        pdf.move_down 2
      end

      report_title =
        case d[:transaction].to_s.upcase
        when "C" then "CORRECTION TO MEDICAL MALPRACTICE\nPAYMENT REPORT"
        else "MEDICAL MALPRACTICE PAYMENT REPORT"
        end

      report_header_block(
        pdf,
        report_title,
        "Date of Action: #{safe(d[:judgment_date] || d[:date_this_payment])}",
        d[:payment_result_of],
        d[:specific_allegation],
        safe(d[:entity_name] || d[:authorized_org_name])
      )

      pdf.move_down 6

      section_sidebar_block(
        pdf,
        "A. REPORTING\nENTITY",
        [
          ["Entity Name:", d[:entity_name]],
          ["Address:", d[:entity_addr1]],
          ["City, State, Zip:", city_state_zip(d[:entity_city], d[:entity_state], d[:entity_zip])],
          ["Country:", ""],
          ["Name or Office:", d[:entity_office]],
          ["Title or Department:", d[:entity_title]],
          ["Telephone:", phone(d[:entity_phone])],
          ["Entity Internal Report Reference:", d[:entity_internal_ref]],
          ["Type of Report:", transaction_label(d[:transaction])],
          ["Previous Report Number:", previous_report(d[:previous_dcn])]
        ]
      )

      section_sidebar_block(
        pdf,
        "B. SUBJECT\nIDENTIFICATION\nINFORMATION\n(INDIVIDUAL)",
        [
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
          ["Social Security Numbers (SSN):", d[:ssn]],
          ["National Provider Identifiers (NPI):", d[:npi]],
          ["Professional School(s) & Year(s) of Graduation:", d[:professional_school]],
          ["Occupation/Field of Licensure:", occupation(d[:occupation_field], d[:occupation_state])],
          ["State License Number, State of Licensure:", license_line(d[:no_license], d[:occupation_state], d[:license_number])],
          ["Drug Enforcement Administration (DEA) Numbers:", d[:dea]],
          ["Hospital Affiliation(s):", d[:hospital_affiliations]]
        ]
      )

      rows = []
      rows << { text: "NOTE: Information marked with an asterisk (*) was added, corrected, or removed.", size: 7 }

      rows += [
        { text: "Date of Report: #{safe(d[:process_date])}" },
        { text: "Relationship of Entity to This Practitioner: #{safe(d[:relationship])}" },

        { text: "PAYMENTS BY THIS PAYER FOR THIS PRACTITIONER", style: :bold },
        { text: "Amount of This Payment for This Practitioner: #{safe(d[:amount_this_payment])}" },
        { text: "Date of This Payment: #{safe(d[:date_this_payment])}" },
        { text: "This Payment Represents: #{payment_type_label(d[:payment_type])}" },
        { text: "Total Amount Paid or to Be Paid by This Payer for This Practitioner: #{safe(d[:total_paid])}" },
        { text: "Payment Result of: #{safe(d[:payment_result_of])}" },
        { text: "Date of Judgment or Settlement, if Any: #{safe(d[:judgment_date])}" },
        { text: "Adjudicative Body Case Number:" },
        { text: "Adjudicative Body Name:" },
        { text: "Court File Number:" },
        { text: "Description of Judgment or Settlement and Any Conditions, Including Terms of Payment: #{safe(d[:judgment_desc])}" },
        { text: "Total Number of Claimants Included in The Settlement: #{safe(d[:claimant_count])}" },

        { text: "PAYMENTS BY THIS PAYER FOR OTHER PRACTITIONERS IN THIS CASE", style: :bold },
        { text: "Total Amount Paid or to Be Paid by This Payer for All Practitioners in This Case: #{safe(d[:other_practitioners_total])}" },
        { text: "Number of Practitioners for Whom This Payer Has Paid or Will Pay in This Case: #{safe(d[:other_practitioners_count])}" },

        { text: "PAYMENTS BY OTHERS FOR THIS PRACTITIONER", style: :bold },
        { text: "Has a State Guaranty Fund or State Excess Judgment Fund Made a Payment for This Practitioner in This Case, or Is Such a Payment Expected to Be Made?: #{safe(d[:state_fund_payment])}" },
        { text: "Amount Paid or Expected to Be Paid by the State Fund:" },
        { text: "Has a Self-Insured Organization and/or Other Insurance Company/Companies Made Payment(s) for This Practitioner in This Case, or Is/Are Such Payment(s) Expected to Be Made?: #{safe(d[:self_insured_payment])}" },
        { text: "Amount Paid or Expected to Be Paid by Self-Insured Organization(s) and/or Other Insurance Company/Companies:" },

        { text: "CLASSIFICATION OF ACT(S) OR OMISSION(S)", style: :bold },
        { text: "Primary Claimant's Age at Time of Initial Event: #{safe(d[:patient_age])}" },
        { text: "Primary Claimant's Sex: #{safe(d[:patient_sex])}" },
        { text: "Primary Claimant's Type: #{safe(d[:patient_type])}" },
        { text: "Description of the Medical Condition With Which the Primary Claimant Presented for Treatment: #{safe(d[:medical_condition_desc])}" },
        { text: "Description of the Procedure Performed: #{safe(d[:procedure_desc])}" },
        { text: "Nature of Allegation: #{safe(d[:nature_allegation])}" },
        { text: "Specific Allegation: #{safe(d[:specific_allegation])}" },
        { text: "Date of Event Associated With Allegation or Incident: #{safe(d[:event_date])}" },
        { text: "* Outcome: #{safe(d[:outcome])}" },
        { text: "Description of the Allegations and Injuries or Illnesses Upon Which the Action or Claim Was Based: #{safe(d[:allegations_desc])}" }
      ]

      section_sidebar_block_rich(pdf, "C. INFORMATION\nREPORTED", rows)
      section_sidebar_block_rich(pdf, "D. SUBJECT\nSTATEMENT", subject_statement_rows(d))
      section_sidebar_block_rich(pdf, "E. REPORT\nSTATUS", report_status_rows(d))

      render_supplemental_section(pdf, d)
      render_maintained_under(pdf, d)
      draw_end_of_report(pdf)
    end

    # ------------------------------------------------------------
    # AAR BODY
    # ------------------------------------------------------------
    def self.render_aar_body(pdf, d)
      pdf.font("Helvetica-Bold")
      pdf.font_size 12
      pdf.text subject_name(d), align: :center
      pdf.move_down 2

      report_header_block(
        pdf,
        "ADVERSE ACTION REPORT",
        "Date of Action: #{safe(d[:finding_date])}",
        d[:action],
        d[:basis_code],
        safe(d[:entity_name] || d[:authorized_org_name])
      )

      pdf.move_down 6

      section_sidebar_block(
        pdf,
        "A. REPORTING\nENTITY",
        [
          ["Entity Name:", d[:entity_name]],
          ["Additional Entity Name:", d[:additional_entity_name]],
          ["Address:", d[:entity_addr1]],
          ["City, State, Zip:", city_state_zip(d[:entity_city], d[:entity_state], d[:entity_zip])],
          ["Name or Office:", d[:entity_office]],
          ["Title or Department:", d[:entity_title]],
          ["Telephone:", phone(d[:entity_phone])],
          ["Entity Internal Report Reference:", d[:entity_internal_ref]],
          ["Type of Report:", transaction_label(d[:transaction])],
          ["Previous Report Number:", previous_report(d[:previous_dcn])]
        ]
      )

      section_sidebar_block(
        pdf,
        "B. SUBJECT\nIDENTIFICATION\nINFORMATION\n(INDIVIDUAL)",
        [
          ["Subject Name:", subject_name(d)],
          ["Other Name(s) Used:", Array(d[:other_names]).join("; ")],
          ["Sex:", d[:sex]],
          ["Date of Birth:", d[:birthdate]],
          ["Organization Name:", d[:org_name]],
          ["Work Address:", d[:work_addr1]],
          ["City, State, ZIP:", city_state_zip(d[:work_city], d[:work_state], d[:work_zip])],
          ["Home Address:", d[:home_addr1]],
          ["City, State, ZIP:", city_state_zip(d[:home_city], d[:home_state], d[:home_zip])],
          ["Social Security Numbers (SSN):", d[:ssn]],
          ["Professional School(s) & Year(s) of Graduation:", d[:professional_school]],
          ["Occupation/Field of Licensure:", occupation(d[:occupation_field], d[:occupation_state])],
          ["State License Number, State of Licensure:", license_line(d[:no_license], d[:occupation_state], d[:license_number])],
          ["Drug Enforcement Administration (DEA) Numbers:", d[:dea]]
        ]
      )

      rows = [
        { text: "Date of Report: #{safe(d[:process_date])}" },
        { text: "Action: #{safe(d[:action])}" },
        { text: "Classification Code: #{safe(d[:classification_code])}" },
        { text: "Finding Date: #{safe(d[:finding_date])}" },
        { text: "Basis Code: #{safe(d[:basis_code])}" },
        { text: "Narrative: #{safe(d[:narrative])}" }
      ]

      section_sidebar_block_rich(pdf, "C. ADVERSE\nACTION", rows)
      section_sidebar_block_rich(pdf, "D. SUBJECT\nSTATEMENT", subject_statement_rows(d))
      section_sidebar_block_rich(pdf, "E. REPORT\nSTATUS", report_status_rows(d))

      render_supplemental_section(pdf, d)
      render_maintained_under(pdf, d)
      draw_end_of_report(pdf)
    end

    # ------------------------------------------------------------
    # COMMON SECTIONS
    # ------------------------------------------------------------
    def self.render_supplemental_section(pdf, d)
      return if d[:supplemental_individual].blank?

      names = Array(d.dig(:supplemental_individual, :names))

      rows = []
      rows << { text: "The following information was not provided by the reporting entity identified in Section A of this report.", size: 8 }

      names.each do |name|
        rows << { text: "Other Name: #{name}", size: 8 }
      end

      Array(d[:other_licenses]).each do |lic|
        rows << {
          text: "Occupation/Field of Licensure: #{safe(lic[:field])} State License Number, State of Licensure: #{safe(lic[:number])}, #{safe(lic[:state])}",
          size: 8
        }
      end

      section_sidebar_block_rich(pdf, "F. SUPPLEMENTAL\nSUBJECT\nINFORMATION ON\nFILE WITH DATA\nBANK", rows)
    end

    def self.render_maintained_under(pdf, d)
      pdf.move_down 8
      pdf.font("Helvetica")
      pdf.font_size 9
      pdf.text "This report is maintained under the provisions of: Title #{safe(d[:maintained_under])}", style: :bold
      pdf.move_down 6

      pdf.text(
        "The information contained in this report is maintained by the National Practitioner Data Bank for restricted use under the provisions of Title IV of Public Law 99-660, as amended, and 45 CFR Part 60. All information is confidential and may be used only for the purpose for which it was disclosed. Disclosure or use of confidential information for other purposes is a violation of federal law. For additional information or clarification, contact the reporting entity identified in Section A.",
        align: :left
      )
    end

    # ------------------------------------------------------------
    # HEADER / FOOTER
    # ------------------------------------------------------------
    def self.header(pdf, d, page_no, page_count)
      pdf.canvas do
        page_top = pdf.page.dimensions[3] - LEFT_MARGIN

        left_x  = LEFT_MARGIN
        right_x = LEFT_MARGIN + 310
        box_h   = 95

        pdf.fill_color "000000"
        pdf.font("Helvetica")
        pdf.font_size 5
        pdf.draw_text "NATIONAL PRACTITIONER DATA BANK", at: [left_x, page_top - 10]

        pdf.font_size 35
        pdf.draw_text "NPDB", at: [left_x, page_top - 38]

        pdf.font_size 9
        pdf.draw_text "P.O. Box 10832", at: [left_x, page_top - 48]
        pdf.draw_text "Chantilly, VA 20153-0832", at: [left_x, page_top - 60]
        pdf.draw_text "https://www.npdb.hrsa.gov", at: [left_x, page_top - 85]

        pdf.stroke_rectangle([right_x, page_top], 230, box_h)

        y = page_top - 12
        gap = 11

        pdf.font("Helvetica-Bold")
        pdf.draw_text "DCN:", at: [right_x + 8, y]
        pdf.font("Helvetica")
        pdf.draw_text safe(d[:dcn]), at: [right_x + 40, y]

        y -= gap
        pdf.draw_text "Process Date: #{safe(d[:process_date])}", at: [right_x + 8, y]
        y -= gap
        pdf.draw_text "Page: #{page_no} of #{page_count}", at: [right_x + 8, y]
        y -= gap
        pdf.draw_text subject_name(d), at: [right_x + 8, y]
        y -= gap
        pdf.draw_text "For authorized use by:", at: [right_x + 8, y]
        y -= gap
        pdf.draw_text safe(d[:authorized_org_name]), at: [right_x + 8, y]

        rule_y = page_top - 100
        pdf.line_width = 2
        pdf.stroke_horizontal_line(LEFT_MARGIN, pdf.page.dimensions[2] - RIGHT_MARGIN, at: rule_y)
        pdf.line_width = 1
      end
    end

    def self.query_summary_header(pdf, d, page_no, page_count)
      header(pdf, d, page_no, page_count)
    end

    def self.footer(pdf)
      pdf.canvas do
        footer_text = "CONFIDENTIAL DOCUMENT - FOR AUTHORIZED USE ONLY"

        pdf.font("Helvetica-Bold")
        pdf.font_size 10

        text_width = pdf.width_of(footer_text, size: 10)
        y = pdf.page.dimensions[1] + 6
        x = (pdf.page.dimensions[2] - text_width) / 2.0

        pdf.draw_text footer_text, at: [x, y]
      end
    end

    # ------------------------------------------------------------
    # BLOCK HELPERS
    # ------------------------------------------------------------
    def self.section_sidebar_block(pdf, sidebar_title, pairs)
      rows = pairs.map do |label, value|
        { text: "#{label} #{safe(value)}".strip, size: SECTION_FONT_SIZE, align: :left }
      end

      section_sidebar_block_rich(pdf, sidebar_title, rows)
    end

    def self.section_sidebar_block_rich(pdf, sidebar_title, rows)
      rows = rows.map do |r|
        {
          text: r[:text].to_s,
          size: (r[:size] || SECTION_FONT_SIZE),
          style: r[:style],
          align: (r[:align] || :left).to_sym,
          type: (r[:type] || :text).to_sym,
          box: (r[:box] || :empty).to_sym,
          box_size: (r[:box_size] || 12).to_f
        }
      end

      pdf.font("Helvetica-Bold")
      pdf.font_size 9

      sidebar_text_h =
        pdf.height_of(sidebar_title, width: SIDEBAR_W - 12, size: 9, leading: 1)

      label_h = sidebar_text_h + 12

      content_h = rows.sum do |r|
        if r[:type] == :checkbox
          text_w = RIGHT_COL_W - r[:box_size] - 6
          text_h = pdf.height_of(r[:text], width: text_w, size: r[:size])
          [r[:box_size], text_h].max + SECTION_LINE_GAP
        else
          pdf.height_of(r[:text], width: RIGHT_COL_W, size: r[:size]) + SECTION_LINE_GAP
        end
      end

      block_h = [label_h, content_h + SECTION_PAD_TOP + SECTION_PAD_BOT].max
      ensure_space!(pdf, block_h + 4)

      start_y = pdf.cursor

      pdf.save_graphics_state
      pdf.stroke_color "000000"
      pdf.line_width 1.2
      pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: start_y)
      pdf.restore_graphics_state

      pdf.save_graphics_state
      pdf.fill_color GREY_SECTION
      pdf.fill_rectangle([0, start_y], SIDEBAR_W, label_h)
      pdf.restore_graphics_state

      pdf.font("Helvetica-Bold")
      pdf.font_size 9
      pdf.text_box(
        sidebar_title,
        at: [6, start_y - 6],
        width: SIDEBAR_W - 12,
        height: label_h,
        valign: :top
      )

      pdf.bounding_box(
        [RIGHT_COL_X, start_y - SECTION_PAD_TOP],
        width: RIGHT_COL_W,
        height: content_h
      ) do
        rows.each do |r|
          if r[:type] == :checkbox
            y = pdf.cursor
            pdf.stroke_rectangle([0, y], r[:box_size], r[:box_size])

            if r[:box] == :x
              pdf.font("Helvetica-Bold")
              pdf.draw_text("X", at: [3, y - (r[:box_size] - 3)])
            end

            pdf.font(r[:style] == :bold ? "Helvetica-Bold" : "Helvetica")
            pdf.font_size(r[:size])

            pdf.bounding_box(
              [r[:box_size] + 6, y],
              width: RIGHT_COL_W - r[:box_size] - 6
            ) { pdf.text(r[:text], align: :left) }

            pdf.move_down SECTION_LINE_GAP
          else
            pdf.font(r[:style] == :bold ? "Helvetica-Bold" : "Helvetica")
            pdf.font_size(r[:size])
            pdf.text(r[:text], align: r[:align])
            pdf.move_down SECTION_LINE_GAP
          end
        end
      end

      pdf.move_cursor_to(start_y - block_h)
    end

    def self.report_header_block(pdf, title, date_right, initial_value, basis_value, org_name)
      org_h   = 25
      title_h = 40
      head_h  = 19
      value_h = 18

      total_h = org_h + title_h + head_h + value_h
      mid_x = CONTENT_WIDTH / 2.0

      y_top = pdf.cursor

      pdf.bounding_box([0, y_top], width: CONTENT_WIDTH, height: total_h) do
        pdf.save_graphics_state
        pdf.stroke_color "9E9E9E"
        pdf.line_width = 1
        pdf.stroke_rectangle([0, total_h], CONTENT_WIDTH, total_h)
        pdf.restore_graphics_state

        cursor_y = total_h

        pdf.fill_color GREY_BAND
        pdf.fill_rectangle([0, cursor_y], CONTENT_WIDTH, org_h)

        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 12
        pdf.text_box(org_name.to_s, at: [0, cursor_y], width: CONTENT_WIDTH, height: org_h, align: :center, valign: :center)

        cursor_y -= org_h
        pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: cursor_y)

        pdf.fill_color GREY_SECTION
        pdf.fill_rectangle([0, cursor_y], CONTENT_WIDTH, title_h)

        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 12
        pdf.text_box(title.to_s, at: [8, cursor_y - 2], width: 360, height: title_h, valign: :center)

        pdf.font_size 9
        pdf.text_box(date_right.to_s, at: [380, cursor_y - 4], width: 150, height: title_h, align: :right, valign: :center)

        cursor_y -= title_h
        pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: cursor_y)

        pdf.fill_color GREY_BAND_DARK
        pdf.fill_rectangle([0, cursor_y], CONTENT_WIDTH, head_h)

        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 12
        pdf.text_box("Initial Action", at: [0, cursor_y - 1], width: mid_x, height: head_h, align: :center, valign: :center)
        pdf.text_box("Basis for Initial Action", at: [mid_x, cursor_y - 2], width: mid_x, height: head_h, align: :center, valign: :center)

        cursor_y -= head_h
        pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: cursor_y)
        pdf.stroke_vertical_line(cursor_y + head_h, cursor_y - value_h, at: mid_x)

        pdf.font("Helvetica")
        pdf.font_size 9
        pad = 8

        pdf.text_box("- #{safe(initial_value)}", at: [pad, cursor_y - 4], width: mid_x - pad * 2, height: value_h, valign: :top)
        pdf.text_box("- #{safe(basis_value)}", at: [mid_x + pad, cursor_y - 4], width: mid_x - pad * 2, height: value_h, valign: :top)
      end

      pdf.move_down 6
    end

    # ------------------------------------------------------------
    # ROW HELPERS
    # ------------------------------------------------------------
    def self.subject_statement_rows(d)
      [
        { text: "If the subject identified in Section B of this report has submitted a statement, it appears in this section.", size: 8, align: :left },
        { text: safe(d[:dispute_status]), size: 8, align: :left }
      ]
    end

    def self.report_status_rows(d)
      first_checked = safe(d[:report_disputed_mark]).present?

      [
        { text: "Unless a box below is checked, the subject of this report identified in Section B has not contested this report.", size: 8, align: :left },
        { text: "", size: 4 },
        { type: :checkbox, box: (first_checked ? :x : :empty), text: "This report has been disputed by the subject identified in Section B.", size: 8 },
        { type: :checkbox, box: :empty, text: "At the request of the subject identified in Section B, this report is being reviewed by the Secretary of the U.S. Department of Health and Human Services to determine its accuracy and/or whether it complies with reporting requirements. No decision has been reached.", size: 8 },
        { type: :checkbox, box: :empty, text: "At the request of the subject identified in Section B, this report was reviewed by the Secretary of the U.S. Department of Health and Human Services and a decision was reached. The subject has requested that the Secretary reconsider the original decision.", size: 8 },
        { type: :checkbox, box: :empty, text: "At the request of the subject identified in Section B, this report was reviewed by the Secretary of the U.S. Department of Health and Human Services. The Secretary's decision is shown below:", size: 8 },
        { text: "Date of Original Submission: #{safe(d[:original_submission_date])}", size: 8 },
        { text: "Date of Most Recent Change: #{safe(d[:most_recent_change_date])}", size: 8 }
      ]
    end

    def self.draw_end_of_report(pdf)
      pdf.move_down 10
      text = "END OF REPORT"
      size = 9

      pdf.font("Helvetica-Bold")
      pdf.font_size(size)

      y = pdf.cursor
      text_w = pdf.width_of(text, size: size)
      gap = 10

      left_end = (CONTENT_WIDTH - text_w) / 2.0 - gap
      right_start = (CONTENT_WIDTH + text_w) / 2.0 + gap

      pdf.save_graphics_state
      pdf.stroke_color "000000"
      pdf.line_width = 2
      pdf.stroke_horizontal_line(0, left_end, at: y)
      pdf.stroke_horizontal_line(right_start, CONTENT_WIDTH, at: y)
      pdf.restore_graphics_state

      pdf.draw_text(text, at: [(CONTENT_WIDTH - text_w) / 2.0, y - 3])
    end

    # ------------------------------------------------------------
    # TEXT HELPERS
    # ------------------------------------------------------------
    def self.safe(v) = v.to_s.strip

    def self.subject_name(d)
      last  = safe(d[:subject_last])
      first = safe(d[:subject_first])
      mid   = safe(d[:subject_middle])
      rest  = [first, mid].reject(&:blank?).join(" ")
      rest.present? ? "#{last}, #{rest}" : last
    end

    def self.phone(raw)
      s = raw.to_s.gsub(/\D/, "")
      return "" if s.blank?
      return "(#{s[0, 3]}) #{s[3, 3]}-#{s[6, 4]}" if s.length >= 10

      raw.to_s
    end

    def self.city_state_zip(city, state, zip)
      a = [safe(city), safe(state)].reject(&:blank?).join(", ")
      b = safe(zip)
      [a, b].reject(&:blank?).join(" ")
    end

    def self.address_line(addr, city, state, zip)
      [safe(addr), city_state_zip(city, state, zip)].reject(&:blank?).join(", ")
    end

    def self.previous_report(dcn)
      s = safe(dcn)
      return "" if s.blank?

      "#{s} (Please destroy all copies of the previous report)"
    end

    def self.occupation(code, state)
      c = safe(code)
      st = safe(state)
      return "" if c.blank? && st.blank?

      [c, (st.present? ? "State #{st}" : nil)].compact.join(" ")
    end

    def self.license_line(no_license, state, number = nil)
      st = safe(state)
      num = safe(number)

      return "" if st.blank? && num.blank? && !no_license
      return "NO LICENSE, #{st}".strip if no_license

      [num, st].reject(&:blank?).join(", ")
    end

    def self.transaction_label(value)
      case safe(value).upcase
      when "I" then "INITIAL"
      when "C" then "CORRECTION"
      when "V" then "VOID"
      else safe(value)
      end
    end

    def self.payment_type_label(value)
      case safe(value).upcase
      when "S" then "A SINGLE FINAL PAYMENT"
      else safe(value).presence || "A SINGLE FINAL PAYMENT"
      end
    end

    def self.query_type_text(d)
      case d[:root_name].to_s
      when "pdsResponse"
        "This is a Continuous Query response."
      else
        "This is a One-Time query response."
      end
    end

    def self.statutes_queried(d)
      statutes = []
      statutes << "Title IV" if safe(d[:title_iv]).present? || true
      statutes << "Section 1921"
      statutes << "Section 1128E"
      statutes.join("; ")
    end

    def self.ensure_space!(pdf, needed_h)
      pdf.start_new_page if pdf.cursor < needed_h
    end
  end
end

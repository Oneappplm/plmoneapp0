# frozen_string_literal: true

# app/services/webscraper/npdb_mmpr_pdf_renderer.rb
require "prawn"
require "tempfile"
require "fileutils"

module Webscraper
  class NpdbMmprPdfRenderer
        PAGE_SIZE     = "LETTER"
    LEFT_MARGIN   = 36
    RIGHT_MARGIN  = 36
    BOTTOM_MARGIN = 22

    HEADER_TOP_PAD     = 18
    HEADER_BOX_H       = 72
    HEADER_RULE_GAP    = 8
    HEADER_NAME_GAP    = 14
    HEADER_ORG_GAP     = 12
    GREY_SECTION       = "D9D9D9"
    GREY_BAND          = "E6E6E6"
    GREY_BAND_DARK     = "CFCFCF"
    FOOTER_H           = 22
    CONTENT_START_PAD  = 0

    TOP_MARGIN    = LEFT_MARGIN + 120
    CONTENT_WIDTH = 540

    SECTION_GAP        = 6
    SECTION_BORDER_GAP = 8
    SECTION_MIN_H      = 0
    SECTION_PAD_TOP    = 10
    SECTION_PAD_BOT    = 8
    SECTION_LINE_GAP   = 2
    SECTION_FONT_SIZE  = 9
    LINE_GAP           = 2

    SIDEBAR_W    = 120
    RIGHT_COL_X  = SIDEBAR_W + 10
    RIGHT_COL_W  = CONTENT_WIDTH - RIGHT_COL_X


    # ✅ Replace previous temp PDF instead of accumulating lots of files
    # - We write to tmp/npdb_mmpr_latest.pdf (overwrites each time)
    # - We return a REAL Tempfile containing the bytes (safe for uploader + cleanup)
    def self.render_to_file!(output_path:, response_xml:, provider_personal_information:, watermark: "")
      FileUtils.mkdir_p(File.dirname(output_path))
      FileUtils.rm_f(output_path)

      data = Webscraper::NpdbMmprXmlParser.new(response_xml).to_h

      data[:subject_last]   = provider_personal_information.last_name.to_s.upcase
      data[:subject_first]  = provider_personal_information.first_name.to_s.upcase
      data[:subject_middle] = provider_personal_information.middle_name.to_s.upcase
      data[:npi]            = provider_personal_information.respond_to?(:npi) ? provider_personal_information.npi.to_s : data[:npi]
      data[:ssn]            = provider_personal_information.respond_to?(:ssn) ? provider_personal_information.ssn.to_s : data[:ssn]

      Prawn::Document.generate(
        output_path.to_s,
        page_size: PAGE_SIZE,
        margin: [TOP_MARGIN, RIGHT_MARGIN, BOTTOM_MARGIN, LEFT_MARGIN]
      ) do |pdf|
        pdf.font("Helvetica")
        pdf.font_size 9

        pdf.repeat(:all, dynamic: true) { header(pdf, data, pdf.page_number, pdf.page_count) }
        pdf.repeat(:all) { footer(pdf) }

        render_body(pdf, data)
      end

      output_path
    end

    # ---------------- BODY ----------------
    # (your existing body/design stays as you have it — no design changes here)
    def self.render_body(pdf, d)
      pdf.move_down CONTENT_START_PAD

      # ---- CENTER SUBJECT/ORG (ONLY PAGE 1) ----
      if pdf.page_number == 1
        name = subject_name(d)
        org  = safe(d[:authorized_org_name])

        block_h = 38
        pdf.bounding_box([0, pdf.cursor], width: CONTENT_WIDTH, height: block_h) do
          pdf.font("Helvetica-Bold")
          pdf.font_size 11
          pdf.text_box(name, at: [0, block_h - 0], width: CONTENT_WIDTH, height: 16, align: :center, valign: :top)

          band_h = 30
          band_y = block_h - 20
          pdf.save_graphics_state
          pdf.fill_color GREY_BAND
          pdf.fill_rectangle([0, band_y], CONTENT_WIDTH, band_h)
          pdf.restore_graphics_state

          pdf.font_size 8.5
          pdf.text_box(org, at: [0, band_y - 2], width: CONTENT_WIDTH, height: band_h, align: :center, valign: :center)
        end
        pdf.move_down 6
      end

      report_header_block(
        pdf,
        "CORRECTION TO MEDICAL MALPRACTICE\nPAYMENT REPORT",
        "Date of Action: #{safe(d[:judgment_date])}",
        d[:payment_result_of],
        d[:specific_allegation]
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
          ["Type of Report:", (d[:transaction].to_s.upcase == "C" ? "CORRECTION" : d[:transaction].to_s)],
          ["Previous Report Number:", previous_report(d[:previous_dcn])]
        ]
      )

      section_sidebar_block(
        pdf,
        "B. SUBJECT\nIDENTIFICATION\nINFORMATION\n(INDIVIDUAL)",
        [
          ["Subject Name:", subject_name(d)],
          ["Other Name(s) Used:", ""],
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
          ["Occupation/Field of Licensure (Code):", occupation(d[:occupation_field], d[:occupation_state])],
          ["License Number, State of Licensure:", license_line(d[:no_license], d[:occupation_state])],
          ["Drug Enforcement Administration (DEA) Numbers:", ""],
          ["Hospital Affiliation(s):", d[:hospital_affiliations]]
        ]
      )

      # ---- C block (keep your existing rows + call) ----
     rows = []
      rows << { text: "NOTE: Information marked with an asterisk (*) was added, corrected, or removed.", size: 7 }

      rows += [
        { text: "Date of Report: #{safe(d[:process_date])}" },
        { text: "Relationship of Entity to This Practitioner: #{safe(d[:relationship])}" },

        { text: "PAYMENTS BY THIS PAYER FOR THIS PRACTITIONER", style: :bold },
        { text: "Amount of This Payment for This Practitioner: #{safe(d[:amount_this_payment])}" },
        { text: "Date of This Payment: #{safe(d[:date_this_payment])}" },

        { text: "This Payment Represents: A SINGLE FINAL PAYMENT" },
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
        { text: "Description of the Medical Condition With Which\n the Primary Claimant Presented for Treatment: #{safe(d[:medical_condition_desc])}" },
        { text: "Description of the Procedure Performed: #{safe(d[:procedure_desc])}" },
        { text: "Nature of Allegation: #{safe(d[:nature_allegation])}" },
        { text: "Specific Allegation: #{safe(d[:specific_allegation])}" },
        { text: "Date of Event Associated With Allegation or Incident: #{safe(d[:event_date])}" },
        { text: "* Outcome: #{safe(d[:outcome])}" },
        { text: "Description of the Allegations and Injuries or Illnesses\n Upon Which the Action or Claim Was Based: #{safe(d[:allegations_desc])}" }
      ]

      section_sidebar_block_rich(pdf, "C. INFORMATION\nREPORTED", rows)


      # --- D. SUBJECT STATEMENT (LEFT aligned like sample) ---
      rows_d_statement = subject_statement_rows(d)
      section_sidebar_block_rich(pdf, "D. SUBJECT\nSTATEMENT", rows_d_statement)


      # --- E. REPORT STATUS (LOCK TO PAGE 3 ONLY) ---
      rows_e = report_status_rows(d)

      # ✅ Only move to a new page IF we are not already on page 3
      pdf.start_new_page if pdf.page_number < 3

      section_sidebar_block_rich(pdf, "E. REPORT\nSTATUS", rows_e)
      
     # --- TOP BORDER for "Maintained under" section ---
      y = pdf.cursor

      pdf.save_graphics_state
      pdf.stroke_color "000000"   # light grey like other sections
      pdf.line_width = 1
      pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: y)
      pdf.restore_graphics_state

      pdf.move_down 8

      pdf.font("Helvetica")
      pdf.font_size 10
      pdf.move_down 4
      pdf.text(
        "This report is maintained under the provisions of: Title #{safe(d[:maintained_under])}".strip,
        align: :left,
        style: :bold
      )

      pdf.move_down 6

      paragraph = "The information contained in this report is maintained by the National Practitioner Data Bank for restricted use under the provisions of Title IV of Public Law 99-660, as amended, and 45 CFR Part 60. All information is confidential and may be used only for the purpose for which it was disclosed. Disclosure or use of confidential information for other purposes is a violation of federal law. For additional information or clarification, contact the reporting entity identified in Section A."

      pdf.text paragraph, align: :left

      # ❗ no extra space at bottom
      pdf.move_down 0

      draw_end_of_report(pdf)
    end
    # ---------------- HEADER / FOOTER / HELPERS ----------------
    # Keep your existing implementations here (no design changes).
    # Make sure you DO NOT reference typos like GREY_SECTIONCONTENT_WIDTH anywhere.

    def self.header(pdf, d, page_no, page_count)
      pdf.canvas do
        page_top = pdf.page.dimensions[3] - LEFT_MARGIN

        left_x  = LEFT_MARGIN
        right_x = LEFT_MARGIN + 310
        box_h   = 95

        # Left NPDB block
        pdf.fill_color "000000"
        pdf.font("Helvetica")
        pdf.font_size 7
        pdf.draw_text "NATIONAL PRACTITIONER DATA BANK", at: [left_x, page_top - 10]

        pdf.font_size 30
        pdf.draw_text "NPDB", at: [left_x, page_top - 32]

        pdf.font_size 8
        pdf.draw_text "P.O. Box 10832", at: [left_x, page_top - 48]
        pdf.draw_text "Chantilly, VA 20153-0832", at: [left_x, page_top - 60]
        pdf.draw_text "https://www.npdb.hrsa.gov", at: [left_x, page_top - 85]

        # Right meta box
        pdf.stroke_rectangle([right_x, page_top], 230, box_h)

        y   = page_top - 12
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

        # Thick rule
        rule_y = page_top - 100
        pdf.line_width = 2
        pdf.stroke_horizontal_line(LEFT_MARGIN, pdf.page.dimensions[2] - RIGHT_MARGIN, at: rule_y)
        pdf.line_width = 1
      end
    end

    def self.footer(pdf)
      pdf.canvas do
        footer_text = "CONFIDENTIAL DOCUMENT - FOR AUTHORIZED USE ONLY"

        pdf.font("Helvetica-Bold")
        pdf.font_size 10   # ⬅ larger than before

        text_width = pdf.width_of(footer_text, size: 10)

        # Y position: very close to bottom, inside margin
        y = pdf.page.dimensions[1] + 6

        # X position: exact center
        x = (pdf.page.dimensions[2] - text_width) / 2.0

        pdf.draw_text footer_text, at: [x, y]
      end
    end

    def self.section_sidebar_block(pdf, sidebar_title, pairs)
      rows = pairs.map { |label, value| { text: "#{label} #{safe(value)}".strip, size: SECTION_FONT_SIZE, align: :center } }
      section_sidebar_block_rich(pdf, sidebar_title, rows)
    end

    def self.section_sidebar_block_rich(pdf, sidebar_title, rows)
      rows = rows.map do |r|
        {
          text: r[:text].to_s,
          size: (r[:size] || SECTION_FONT_SIZE),
          style: r[:style],
          align: (r[:align] || :center).to_sym,
          type: (r[:type] || :text).to_sym,
          box: (r[:box] || :empty).to_sym,
          box_size: (r[:box_size] || 12).to_f
        }
      end

      # --- measure sidebar ---
      pdf.font("Helvetica-Bold")
      pdf.font_size 9
      sidebar_text_h = pdf.height_of(
        sidebar_title,
        width: SIDEBAR_W - 12,
        size: 9,
        leading: 1
      )
      label_h = sidebar_text_h + 12

      # --- measure content ---
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

      # --- top border ---
      pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: start_y)

      # --- sidebar background (FIXED COLOR BUG) ---
      pdf.save_graphics_state
      pdf.fill_color GREY_SECTION
      pdf.fill_rectangle([0, start_y], SIDEBAR_W, label_h)
      pdf.restore_graphics_state

      # --- sidebar title ---
      pdf.font("Helvetica-Bold")
      pdf.font_size 9
      pdf.text_box(
        sidebar_title,
        at: [6, start_y - 6],
        width: SIDEBAR_W - 12,
        height: label_h,
        valign: :top
      )

      # --- content ---
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

      # ✅ minimal spacing after section (NO footer gap)
      pdf.move_cursor_to(start_y - block_h)
    end

    def self.centered_lines(pdf, pairs)
      pairs.each do |label, value|
        line = "#{label} #{safe(value)}".strip
        pdf.text line, align: :left
        pdf.move_down LINE_GAP
      end
    end

    def self.report_header_block(pdf, title, date_right, initial_value, basis_value)
      title_h = 34
      head_h  = 18
      value_h = 18
      total_h = title_h + head_h + value_h

      mid_x = CONTENT_WIDTH / 2.0

      outer_stroke = "404040" # light grey border like sample
      inner_stroke = "C8C8C8" # inner grid like sample

      y_top = pdf.cursor

      pdf.bounding_box([0, y_top], width: CONTENT_WIDTH, height: total_h) do
        # Outer border
        pdf.save_graphics_state
        pdf.stroke_color outer_stroke
        pdf.line_width = 1
        pdf.stroke_rectangle([0, total_h], CONTENT_WIDTH, total_h)
        pdf.restore_graphics_state

        # Title band
        pdf.save_graphics_state
        pdf.fill_color "D3D3D3"
        pdf.fill_rectangle([0, total_h], CONTENT_WIDTH, title_h)
        pdf.restore_graphics_state

        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 11

        pdf.text_box(
          title.to_s,                      # "CORRECTION TO MEDICAL MALPRACTICE\nPAYMENT REPORT"
          at: [8, total_h - 2],
          width: 380,
          height: title_h,
          leading: 1,
          valign: :center
        )

        pdf.font_size 10
        pdf.text_box(
          date_right.to_s,                 # "Date of Action: ..."
          at: [390, total_h - 6],
          width: 142,
          height: title_h,
          align: :right,
          valign: :center
        )

        # line under title
        pdf.save_graphics_state
        pdf.stroke_color inner_stroke
        pdf.line_width = 0.8
        pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: total_h - title_h)
        pdf.restore_graphics_state

        # header band
        header_top = total_h - title_h
        pdf.save_graphics_state
        pdf.fill_color GREY_BAND_DARK
        pdf.fill_rectangle([0, header_top], CONTENT_WIDTH, head_h)
        pdf.restore_graphics_state

        pdf.fill_color "000000"
        pdf.font("Helvetica-Bold")
        pdf.font_size 9
        pdf.text_box("Initial Action", at: [0, header_top - 3], width: mid_x, height: head_h, align: :center, valign: :center)
        pdf.text_box("Basis for Initial Action", at: [mid_x, header_top - 3], width: mid_x, height: head_h, align: :center, valign: :center)

        # line under header
        values_top = header_top - head_h
        pdf.save_graphics_state
        pdf.stroke_color inner_stroke
        pdf.line_width = 0.8
        pdf.stroke_horizontal_line(0, CONTENT_WIDTH, at: values_top)
        pdf.restore_graphics_state

        # vertical divider through header+values
        pdf.save_graphics_state
        pdf.stroke_color inner_stroke
        pdf.line_width = 0.8
        pdf.stroke_vertical_line(header_top, 0, at: mid_x)
        pdf.restore_graphics_state

        # values (TOP aligned, not bottom)
        left_text  = "- #{safe(initial_value)}".strip
        right_text = "- #{safe(basis_value)}".strip

        pdf.font("Helvetica")
        pdf.font_size 9
        pad_left = 8
        pad_top  = 2

        pdf.text_box(left_text,  at: [pad_left, values_top - pad_top], width: mid_x - (pad_left * 2), height: value_h, valign: :top)
        pdf.text_box(right_text, at: [mid_x + pad_left, values_top - pad_top], width: mid_x - (pad_left * 2), height: value_h, valign: :top)
      end
    end

    # -------------------------------------------------------------------
    # --- ADD these helpers (D rows, E rows, keep-together, END OF REPORT) ---

    def self.subject_statement_rows(d)
      [
        { text: "If the subject identified in Section B of this report has submitted a statement, it appears in this section.", size: 8, align: :left },
        { text: "Queries, please note:", size: 8, style: :bold, align: :left },
        {
          text: "The practitioner/subject entered the statement shown below in response to an earlier version of this report. The reporting entity changed the report after the practitioner/subject prepared the statement. As of the date this query response was processed, the practitioner/subject has not changed the statement in response to the changes in the report.",
          size: 7,
          align: :left
        },
        { text: "", size: 5, align: :left },
        { text: "Date Submitted: #{safe(d[:process_date])}", size: 8, align: :left },
        { text: safe(d[:dispute_status]), size: 8, align: :left }
      ]
    end

    def self.report_status_rows(d)
      # If you later add real flags from XML, swap these.
      # For now: if report_disputed_mark present => first box checked.
      mark = safe(d[:report_disputed_mark])
      first_checked = mark.present? && mark != " " && mark != "0"

      # Some templates show the THIRD box checked depending on workflow; you can map it here:
      third_checked = safe(d[:report_reviewed_reconsidered_mark]).present?

      date_sub = safe(d[:process_date])
      orig_sub = safe(d[:original_submission_date]).presence || date_sub
      most_chg = safe(d[:most_recent_change_date]).presence || date_sub

      rows = []
      rows << { text: "Unless a box below is checked, the subject of this report identified in Section B has not contested this report.", size: 8, align: :left }
      rows << { text: "", size: 4, align: :left }

      rows << { type: :checkbox, box: (first_checked ? :x : :empty), text: "This report has been disputed by the subject identified in Section B.", size: 8 }

      rows << {
        type: :checkbox, box: :empty, size: 8,
        text: "At the request of the subject identified in Section B, this report is being reviewed by the Secretary of the U.S. Department of Health and Human Services to determine its accuracy and/or whether it complies with reporting requirements. No decision has been reached."
      }

      rows << {
        type: :checkbox, box: (third_checked ? :x : :empty), size: 8,
        text: "At the request of the subject identified in Section B, this report was reviewed by the Secretary of the U.S. Department of Health and Human Services and a decision was reached. The subject has requested that the Secretary reconsider the original decision."
      }

      rows << {
        type: :checkbox, box: :empty, size: 8,
        text: "At the request of the subject identified in Section B, this report was reviewed by the Secretary of the U.S. Department of Health and Human Services. The Secretary's decision is shown below:"
      }

      rows << { text: "", size: 4, align: :left }

      # ✅ include the Queries note block (your screenshot shows this must appear)
      rows << { text: "Queries, please note:", size: 8, style: :bold, align: :left }
      rows << {
        text: "The Secretary of the Department of Health and Human Services reviewed an earlier version of this report and entered the statement shown below. After the Dispute Resolution decision and statement were entered, the reporting entity changed the report. The Secretary has not reviewed the current version of the report.",
        size: 7,
        align: :left
      }

      rows << { text: "", size: 4, align: :left }

      rows << { text: "Date Submitted: #{date_sub}", size: 8, align: :left }
      rows << { text: safe(d[:dispute_status]), size: 8, align: :left }
      rows << { text: "Date of Original Submission: #{orig_sub}", size: 8, align: :left }
      rows << { text: "Date of Most Recent Change: #{most_chg}", size: 8, align: :left }

      rows
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
    
    def self.center_x(pdf, text, size)
      w = pdf.width_of(text.to_s, size: size)
      (CONTENT_WIDTH - w) / 2.0
    end

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
      return "(#{s[0,3]}) #{s[3,3]}-#{s[6,4]}" if s.length >= 10
      raw.to_s
    end

    def self.city_state_zip(city, state, zip)
      a = [safe(city), safe(state)].reject(&:blank?).join(", ")
      b = safe(zip)
      [a, b].reject(&:blank?).join(" ")
    end

    def self.previous_report(dcn)
      s = safe(dcn)
      return "" if s.blank?
      "#{s} (Please destroy all copies of the previous report)"
    end

    def self.occupation(code, state)
      c  = safe(code)
      st = safe(state)
      return "" if c.blank? && st.blank?
      label = (c == "603" ? "CHIROPRACTOR" : c)
      [label, (st.present? ? "State #{st}" : nil)].compact.join(" ")
    end

    def self.license_line(no_license, state)
      st = safe(state)
      return "" if st.blank? && !no_license
      no_license ? "NO LICENSE, #{st}".strip : ", #{st}".strip
    end

    def self.ensure_space!(pdf, needed_h)
      pdf.start_new_page if pdf.cursor < needed_h
    end
  end
end

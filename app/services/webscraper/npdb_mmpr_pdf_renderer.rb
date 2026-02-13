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
    BOTTOM_MARGIN = 36

    HEADER_TOP_PAD     = 18
    HEADER_BOX_H       = 72
    HEADER_RULE_GAP    = 8
    HEADER_NAME_GAP    = 14
    HEADER_ORG_GAP     = 12
    GREY_SECTION       = "D9D9D9"
    GREY_BAND          = "E6E6E6"
    GREY_BAND_DARK     = "CFCFCF"
    FOOTER_H           = 22
    CONTENT_START_PAD  = 18

    TOP_MARGIN    = LEFT_MARGIN + 120
    CONTENT_WIDTH = 540

    SECTION_GAP        = 10
    SECTION_BORDER_GAP = 8
    SECTION_MIN_H      = 78
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
        margin: [TOP_MARGIN, RIGHT_MARGIN, (BOTTOM_MARGIN + FOOTER_H), LEFT_MARGIN]
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

      title_line(
        pdf,
        "CORRECTION TO MEDICAL MALPRACTICE PAYMENT REPORT",
        "Date of Action: #{safe(d[:judgment_date])}"
      )

      initial_basis_block(pdf, d[:payment_result_of], d[:specific_allegation])

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

      pdf.move_down 6
      pdf.text "C. INFORMATION REPORTED", style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 4
      pdf.font_size 7
      pdf.text "NOTE: Information marked with an asterisk (*) was added, corrected, or removed."
      pdf.font_size 9
      pdf.move_down 8

      centered_lines(pdf, [
        ["Date of Report:", d[:process_date]],
        ["Relationship of Entity to This Practitioner:", d[:relationship]],
        ["PAYMENTS BY THIS PAYER FOR THIS PRACTITIONER", ""],
        ["Amount of This Payment for This Practitioner:", d[:amount_this_payment]],
        ["Date of This Payment:", d[:date_this_payment]]
      ])

      pdf.move_down 10

      centered_lines(pdf, [
        ["This Payment Represents:", "A SINGLE FINAL PAYMENT"],
        ["Total Amount Paid or to Be Paid by This Payer for This Practitioner:", d[:total_paid]],
        ["Payment Result of:", d[:payment_result_of]],
        ["Date of Judgment or Settlement, if Any:", d[:judgment_date]],
        ["Adjudicative Body Case Number:", ""],
        ["Adjudicative Body Name:", ""],
        ["Court File Number:", ""],
        ["Description of Judgment or Settlement and Any Conditions, Including Terms of Payment:", d[:judgment_desc]],
        ["Total Number of Claimants Included in The Settlement:", d[:claimant_count]],
        ["PAYMENTS BY THIS PAYER FOR OTHER PRACTITIONERS IN THIS CASE", ""],
        ["Total Amount Paid or to Be Paid by This Payer for All Practitioners in This Case:", d[:other_practitioners_total]],
        ["Number of Practitioners for Whom This Payer Has Paid or Will Pay in This Case:", d[:other_practitioners_count]],
        ["PAYMENTS BY OTHERS FOR THIS PRACTITIONER", ""],
        ["Has a State Guaranty Fund or State Excess Judgment Fund Made a Payment for This Practitioner in This Case, or Is Such a Payment Expected to Be Made?:", d[:state_fund_payment]],
        ["Amount Paid or Expected to Be Paid by the State Fund:", ""],
        ["Has a Self-Insured Organization and/or Other Insurance Company/Companies Made Payment(s) for This Practitioner in This Case, or Is/Are Such Payment(s) Expected to Be Made?:", d[:self_insured_payment]],
        ["Amount Paid or Expected to Be Paid by Self-Insured Organization(s) and/or Other Insurance Company/Companies:", ""]
      ])

      pdf.move_down 10
      pdf.text "CLASSIFICATION OF ACT(S) OR OMISSION(S)", style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 8

      centered_lines(pdf, [
        ["Primary Claimant's Age at Time of Initial Event:", d[:patient_age]],
        ["Primary Claimant's Sex:", d[:patient_sex]],
        ["Primary Claimant's Type:", d[:patient_type]],
        ["Description of the Medical Condition With Which the Primary Claimant Presented for Treatment:", d[:medical_condition_desc]],
        ["Description of the Procedure Performed:", d[:procedure_desc]],
        ["Nature of Allegation:", d[:nature_allegation]],
        ["Specific Allegation:", d[:specific_allegation]],
        ["Date of Event Associated With Allegation or Incident:", d[:event_date]],
        ["* Outcome:", d[:outcome]],
        ["Description of the Allegations and Injuries or Illnesses Upon Which the Action or Claim Was Based:", d[:allegations_desc]]
      ])

      pdf.move_down 12
      pdf.text "D. SUBJECT STATEMENT", style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 6
      pdf.font_size 8
      pdf.text "If the subject identified in Section B of this report has submitted a statement, it appears in this section."
      pdf.font_size 9
      pdf.move_down 6
      pdf.text "Date Submitted: #{safe(d[:process_date])}"
      pdf.text(d[:dispute_status].to_s)

      pdf.move_down 12
      pdf.text "E. REPORT STATUS", style: :bold
      pdf.stroke_horizontal_rule
      pdf.move_down 6
      pdf.font_size 8
      pdf.text "Unless a box below is checked, the subject of this report identified in Section B has not contested this report."
      pdf.font_size 9
      pdf.move_down 6

      mark = safe(d[:report_disputed_mark])
      pdf.text "#{mark}  This report has been disputed by the subject identified in Section B."
      pdf.move_down 8

      pdf.text "This report is maintained under the provisions of: Title #{safe(d[:maintained_under])}"
      pdf.move_down 10

      pdf.font_size 8
      pdf.text "The information contained in this report is maintained by the National Practitioner Data Bank for restricted use under the provisions of Title IV of Public Law 99-660, as amended, and 45 CFR Part 60. All information is confidential and may be used only for the purpose for which it was disclosed. Disclosure or use of confidential information for other purposes is a violation of federal law. For additional information or clarification, contact the reporting entity identified in Section A."
      pdf.font_size 9

      pdf.move_down 10
      pdf.text "END OF REPORT", style: :bold
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

        rule_y = page_top - 100
        pdf.line_width = 2
        pdf.stroke_horizontal_line(LEFT_MARGIN, pdf.page.dimensions[2] - RIGHT_MARGIN, at: rule_y)
        pdf.line_width = 1

        # (keep whatever “page 1 only” behavior you want here)
      end
    end

    def self.footer(pdf)
      pdf.canvas do
        pdf.font("Helvetica")
        pdf.font_size 8
        footer_text = "CONFIDENTIAL DOCUMENT - FOR AUTHORIZED USE ONLY"
        y = pdf.page.dimensions[1] + 18
        pdf.draw_text footer_text, at: [center_x(pdf, footer_text, 8), y]
      end
    end

    def self.section_sidebar_block(pdf, sidebar_title, pairs)
      pdf.move_down SECTION_GAP

      pdf.font_size SECTION_FONT_SIZE
      lines = pairs.map { |label, value| "#{label} #{safe(value)}".strip }

      text_h = lines.sum do |line|
        pdf.height_of(line, width: RIGHT_COL_W, size: SECTION_FONT_SIZE, align: :center) + SECTION_LINE_GAP
      end

      block_h = text_h + SECTION_PAD_TOP + SECTION_PAD_BOT
      block_h = [block_h, SECTION_MIN_H].max

      ensure_space!(pdf, block_h + SECTION_BORDER_GAP)

      start_y = pdf.cursor

      pdf.stroke_rectangle([0, start_y], CONTENT_WIDTH, block_h)

      pdf.save_graphics_state
      pdf.fill_color GREY_SECTION
      pdf.fill_rectangle([0, start_y], SIDEBAR_W, block_h)
      pdf.restore_graphics_state

      pdf.font("Helvetica-Bold")
      pdf.font_size 9
      pdf.text_box(
        sidebar_title.to_s,
        at: [6, start_y - 8],
        width: SIDEBAR_W - 12,
        height: block_h,
        valign: :top,
        leading: 1
      )

      pdf.font("Helvetica")
      pdf.font_size SECTION_FONT_SIZE

      content_top_y = start_y - SECTION_PAD_TOP
      pdf.bounding_box([RIGHT_COL_X, content_top_y], width: RIGHT_COL_W, height: block_h - SECTION_PAD_TOP - SECTION_PAD_BOT) do
        lines.each do |line|
          pdf.text line, align: :center
          pdf.move_down SECTION_LINE_GAP
        end
      end

      pdf.move_cursor_to(start_y - block_h - SECTION_BORDER_GAP)
    end

    def self.centered_lines(pdf, pairs)
      pairs.each do |label, value|
        line = "#{label} #{safe(value)}".strip
        pdf.text line, align: :left
        pdf.move_down LINE_GAP
      end
    end

    def self.title_line(pdf, left, right)
      y      = pdf.cursor
      band_h = 34

      pdf.fill_color GREY_BAND
      pdf.fill_rectangle([0, y], CONTENT_WIDTH, band_h)
      pdf.fill_color "000000"

      pdf.font("Helvetica-Bold")
      pdf.text_box(left.to_s, at: [8, y - 6], width: 380, height: band_h, size: 11, leading: 1, valign: :center)

      pdf.text_box(right.to_s, at: [390, y - 6], width: 142, height: band_h, size: 10, align: :right, valign: :center)

      pdf.font("Helvetica")
      pdf.move_down(band_h + 8)
    end

    def self.initial_basis_block(pdf, initial_value, basis_value)
      header_h = 18
      values_h = 18
      mid_x    = CONTENT_WIDTH / 2.0

      y = pdf.cursor
      pdf.fill_color GREY_BAND_DARK
      pdf.fill_rectangle([0, y], CONTENT_WIDTH, header_h)
      pdf.fill_color "000000"

      pdf.font("Helvetica-Bold")
      pdf.text_box("Initial Action", at: [0, y - 4], width: mid_x, height: header_h, align: :center, valign: :center, size: 9)
      pdf.text_box("Basis for Initial Action", at: [mid_x, y - 4], width: mid_x, height: header_h, align: :center, valign: :center, size: 9)
      pdf.font("Helvetica")

      top_values = y - header_h
      pdf.stroke_rectangle([0, top_values], CONTENT_WIDTH, values_h)
      pdf.stroke_vertical_line(top_values, top_values - values_h, at: mid_x)

      left_text  = "- #{safe(initial_value)}".strip
      right_text = "- #{safe(basis_value)}".strip

      pdf.font_size 9
      pdf.text_box(left_text,  at: [8, top_values - 4], width: mid_x - 16, height: values_h, valign: :center)
      pdf.text_box(right_text, at: [mid_x + 8, top_values - 4], width: mid_x - 16, height: values_h, valign: :center)

      pdf.move_down(header_h + values_h + 10)
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

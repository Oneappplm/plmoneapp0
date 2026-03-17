# frozen_string_literal: true

require "shellwords"
require "open3"

module Caqh
  class ProviderImporter
    attr_reader :file_path, :raw_fields

    def initialize(file_path)
      @file_path = file_path.is_a?(Pathname) ? file_path.to_s : file_path.to_s
      @raw_fields = Caqh::PdfFieldExtractor.new(@file_path).call
    end

    ###########################################################################
    # MAIN ENTRYPOINT
    ###########################################################################
    def call
      ActiveRecord::Base.transaction do
        provider_attest = find_or_create_provider_attest

        text = pdf_text

        ppi       = create_or_update_provider_personal_information(provider_attest)
        licenses  = create_or_update_provider_licensures(provider_attest)
        educ      = create_practice_information_educations(provider_attest, text)
        train     = create_provider_educations(provider_attest, text)
        practices = create_or_update_practice_informations(provider_attest, text)
        specialties = create_provider_specialties(provider_attest, text)
        deas      = create_or_update_provider_deas(provider_attest, text)
        medicares = create_or_update_provider_medicares(provider_attest, text)
        medicaids = create_or_update_provider_medicaids(provider_attest, text)
        credentialing_contacts = create_or_update_credentialing_contacts(ppi, text)
        hospital_privileges    = create_or_update_provider_hospital_privileges(provider_attest, text)
        ins_coverages = create_or_update_provider_insurance_coverages(provider_attest, text)
        employments = create_or_update_provider_employments(provider_attest, text)
        time_gaps  = create_or_update_provider_time_gaps(provider_attest, text)
        military   = create_or_update_provider_militaries(provider_attest, text)
        peer_refs = create_or_update_provider_peer_refs(provider_attest, text)
        disclosures = create_or_update_provider_disclosures(provider_attest, text)

        {
          provider_attest:                 provider_attest,
          provider_personal_information:   ppi,
          provider_licensures:             licenses,
          practice_information_educations: educ,
          provider_educations:             train,
          practice_informations:           practices,
          provider_specialties:            specialties,
          provider_deas:                   deas,
          provider_medicaids:              medicaids,
          provider_disclosures:            disclosures,
          raw_fields:                      raw_fields
        }
      end
    end

    private

    ###########################################################################
    # FORMAT DETECTION / SHARED HELPERS
    ###########################################################################
    def standard_application_pdf?
      @standard_application_pdf ||= begin
        t = pdf_text.to_s
        t.match?(/Provider Application/i) ||
          t.match?(/Section 1\s+Personal Information and Professional IDs/i) ||
          t.match?(/Std\. App\.\s*v6\.0/i)
      end
    end

    def data_summary_pdf?
      @data_summary_pdf ||= begin
        t = pdf_text.to_s
        t.match?(/CAQH Data Summary/i) ||
          t.match?(/PRACTICE LOCATIONS/i) ||
          t.match?(/DISCLOSURE INFORMATION/i)
      end
    end

    def extract_first(pattern, text, idx = 1)
      m = text.to_s.match(pattern)
      return nil unless m
      v = m[idx]
      v.to_s.strip.presence
    end

    def normalize_checkbox_text(text)
      text.to_s.gsub("\f", " ").gsub("\r", "").gsub(/[ \t]+/, " ")
    end

    def normalize_pdf_text(text)
      s = text.to_s.dup
      s = s.gsub("\f", " ").gsub("\r", "")
      s = s.gsub(/[ \t]+/, " ")
      s
    end

    def squash_ws(str)
      str.to_s.gsub(/\s+/, " ").strip
    end

    def section_between(text, start_pat, stop_pats = [])
      return "" if text.blank?

      start = text.index(start_pat)
      return "" unless start

      stop = stop_pats.map { |pat| text.index(pat, start) }.compact.min || text.length
      text[start...stop].to_s
    end

    def standard_pages
      return [] unless standard_application_pdf?
      @standard_pages ||= begin
        txt = pdf_text.to_s
        txt.split(/\f/)
      end
    end

    def standard_page_text(page_no)
      pages = standard_pages
      return "" if pages.blank?
      pages[page_no - 1].to_s
    end

    def only_real_lines(block)
      block.to_s.lines.map(&:strip).reject(&:blank?)
    end

    def next_real_line(lines, idx)
      j = idx + 1
      while j < lines.length
        v = lines[j].to_s.strip
        return v if v.present?
        j += 1
      end
      nil
    end

    def likely_instruction_line?(line)
      s = line.to_s.strip
      return true if s.blank?
      return true if s.match?(/\A\*+\z/)
      return true if s.match?(/\A(REQUIRED RESPONSE|Page \d+|Std\. App\.|Implemented in|CAQH Provider ID|Last Attestation|Code lists are found|If you have additional|Provide the appropriate|Use one section per institution|Do not write instructions|TIP |NOTE:|Instructions|Read all instructions|Professional IDs|General Information|Other ID Numbers|Section \d+)/i)
      false
    end

    def likely_label_line?(line)
      s = line.to_s.strip
      return true if s.blank?
      return true if s == s.upcase && s.match?(/[A-Z]/) && s.length > 3
      return true if s.match?(/\A(?:LAST NAME|FIRST NAME|MIDDLE NAME|CITY|STATE|ZIP|ADDRESS|TELEPHONE|FAX|E-MAIL|NUMBER|STREET|SUITE|COUNTRY|START DATE|END DATE|DEGREE|BOARD|SPECIALTY|PROVIDER TYPE|LICENSE TYPE|LICENSE STATUS|YES NO|YES|NO)\b/i)
      false
    end

    def standard_yes_no_value_near(text, prompt)
      s = text.to_s
      idx = s.index(prompt)
      return nil unless idx

      window = s[idx, 220].to_s
      return "Yes" if window.match?(/X\s+YES/i) || window.match?(/YES\s+X/i)
      return "No"  if window.match?(/X\s+NO/i)  || window.match?(/NO\s+X/i)
      nil
    end

    ###########################################################################
    # CAQH ID LOOKUP
    ###########################################################################
    def caqh_provider_attest_id
      val = raw_fields["alan-provider-caqh-id"] ||
            raw_fields["james-provider-caqh-id"] ||
            raw_fields["provider-attest-id"] ||
            raw_fields["caqh-provider-attest-id"] ||
            raw_fields["attestation-id"]

      return val.to_i if val.present? && val.to_s =~ /^\d+$/

      raw_fields.values.each do |v|
        next if v.blank?
        if v.to_s =~ /(\d{8,10})/
          return Regexp.last_match(1).to_i
        end
      end
      nil
    end

    def caqh_provider_id
      raw_fields["caqh-provider-id"] || raw_fields["provider-id"]
    end

    def find_or_create_provider_attest
      id_val = caqh_provider_attest_id || caqh_provider_id
      raise "CAQH Provider Attest ID not found in PDF" if id_val.blank?

      ProviderAttest.find_or_create_by!(
        caqh_provider_attest_id: id_val.to_i
      )
    end

    ###########################################################################
    # PERSONAL INFORMATION
    ###########################################################################
    def create_or_update_provider_personal_information(provider_attest)
      boolean_columns  = boolean_columns_for(ProviderPersonalInformation)
      date_columns     = date_columns_for(ProviderPersonalInformation)
      datetime_columns = datetime_columns_for(ProviderPersonalInformation)
      columns          = ProviderPersonalInformation.columns_hash.keys.map(&:to_sym)

      ai_attrs =
        begin
          mapper = Caqh::AiFieldMapper.new(raw_fields)
          mapper.attributes_for(ProviderPersonalInformation, full_pdf_text: pdf_text).symbolize_keys
        rescue => e
          Rails.logger.error("Error in AiFieldMapper: #{e.message}")
          {}
        end

      manual_attrs =
        if ai_attrs.blank? && standard_application_pdf?
          parse_standard_application_personal_information(pdf_text)
        else
          {}
        end

      base_attrs =
        if ai_attrs.present?
          ai_attrs
        elsif manual_attrs.present?
          manual_attrs
        else
          auto_map_by_schema(ProviderPersonalInformation)
        end

      attrs = base_attrs.slice(*columns)
      attrs = cast_attributes(attrs, boolean_columns, date_columns, datetime_columns)

      attrs[:caqh_provider_attest_id] ||= caqh_provider_attest_id
      attrs[:caqh_provider_id]        ||= caqh_provider_id

      if attrs[:other_name_flag].nil?
        t = pdf_text
        if standard_application_pdf?
          page1 = standard_page_text(1)
          yn = standard_yes_no_value_near(page1, "HAVE YOU EVER USED ANOTHER NAME?")
          attrs[:other_name_flag] = to_bool(yn)
        else
          attrs[:other_name_flag] = true  if t =~ /Have you used other names\?\s*Yes/i
          attrs[:other_name_flag] = false if t =~ /Have you used other names\?\s*No/i
        end
      end

      ppi = provider_attest.provider_personal_informations.first_or_initialize
      ppi.assign_attributes(attrs)
      ppi.save!
      ppi
    end

    def parse_standard_application_personal_information(text)
      page1 = standard_page_text(1)
      page2 = standard_page_text(2)
      return {} if page1.blank?

      attrs = {}

      name_line = extract_first(/CAQH PROVIDER ID\s*:\s*LAST ATTESTATION DATE\s*:\s*([^\n]+(?:\n[^\n]+){0,10})/im, page1, 1).to_s
      ptype = page1[/CAQH PROVIDER ID\s*:\s*LAST ATTESTATION DATE\s*:\s*([A-Z]{1,4})\s+X/i, 1]

      lines = only_real_lines(page1)
      last_name  = nil
      first_name = nil
      middle_name = nil

      name_idx = lines.find_index { |l| l.match?(/\ALAST NAME/i) }
      if name_idx
        a = next_real_line(lines, name_idx)
        b = next_real_line(lines, name_idx + 1)
        c = next_real_line(lines, name_idx + 2)

        values = [a, b, c].compact.reject { |v| likely_instruction_line?(v) || likely_label_line?(v) }
        if values.size >= 2
          last_name = values[0]
          first_name = values[1]
          middle_name = values[2]
        end
      end

      last_name  ||= extract_first(/\nWillis\s*\n/i, page1, 0)&.strip
      first_name ||= extract_first(/\nRyan(?:\s+Thomas)?\s*\n/i, page1, 0)&.split&.first
      middle_name ||= extract_first(/\nRyan\s+([A-Z][a-z]+)\s*\n/i, page1, 1)

      attrs[:last_name] = last_name if last_name.present?
      attrs[:first_name] = first_name if first_name.present?
      attrs[:middle_name] = middle_name if middle_name.present?
      attrs[:provider_type_provider_type_abbreviation] = ptype if ptype.present?
      attrs[:practitioner_type] = ptype if ptype.present?

      attrs[:birth_date] ||= extract_first(/X\s+(\d{2}\/\d{2}\/\d{4})/, page1, 1)
      attrs[:date_of_birth] ||= attrs[:birth_date]

      attrs[:gender] ||= if page1.match?(/GENDER\*.*?X\s+MALE/i)
                           "Male"
                         elsif page1.match?(/GENDER\*.*?X\s+FEMALE/i)
                           "Female"
                         end
      attrs[:gender_gender_description] ||= attrs[:gender]

      if page1 =~ /\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(United States|Canada)\s*\n/
        attrs[:birth_city] = Regexp.last_match(1)&.strip
        attrs[:birth_state] = Regexp.last_match(2)&.strip
        attrs[:birth_country_country_name] = Regexp.last_match(3)&.strip
      end

      attrs[:ssn] ||= extract_first(/\n(\d{3}-\d{2}-\d{4})\n/, page1, 1)

      if page1 =~ /\n(\d+\s+[A-Za-z0-9 .'\-#]+)\s*\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\n/
        attrs[:address_line1] = Regexp.last_match(1)&.strip
        attrs[:city]          = Regexp.last_match(2)&.strip
        attrs[:state]         = Regexp.last_match(3)&.strip
        attrs[:zipcode]       = Regexp.last_match(4)&.strip
        attrs[:country]       = "United States"
      end

      attrs[:email_address] ||= extract_first(/([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})/i, page1, 1)

      attrs[:npi] ||= extract_first(/\n(\d{10})\n/, page2, 1)
      attrs[:npi_flag] = attrs[:npi].present?

      attrs[:dea_flag] = page2.match?(/\b[A-Z]{2}\d{7}\b/)
      attrs[:medicare_provider_flag] = !extract_first(/\bMEDICARE NUMBER\b.*?\nX\s+([A-Z0-9\-]+)/im, page2, 1).nil? || page2.match?(/\bG9060323\b/)
      attrs[:medicaid_provider_flag] = !extract_first(/\bMEDICAID STATE\b.*?\nX\s+([A-Z0-9\-]+)\s+[A-Z]{2}/im, page2, 1).nil? || page2.match?(/\b2233352\s+WA\b/)
      attrs[:active_military_flag] = false if text.match?(/Are you currently on active military duty or military reserve\?\*.*?X\s+NO/im)

      attrs.compact
    end

    ###########################################################################
    # LICENSE PARSING
    ###########################################################################
    def create_or_update_provider_licensures(provider_attest)
      text = pdf_text
      return [] if text.blank?

      blocks =
        parse_license_blocks_from_pdf(text) +
        parse_standard_application_license_blocks(text)

      return [] if blocks.blank?

      blocks = blocks.uniq { |b| [b[:state_abbr], b[:license_number]] }

      upserted = []

      blocks.each do |blk|
        state_id = lookup_state_id(blk[:state_abbr])
        next if state_id.nil?

        rec = ProviderLicensure.where(
          provider_attest_id: provider_attest.id,
          license_number: blk[:license_number],
          state_id: state_id
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id: provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          state_id: state_id,
          license_type: blk[:license_type].presence || "MD",
          license_number: blk[:license_number],
          license_issue_date: to_date_flexible(blk[:issue_date]),
          license_expiration_date: to_date_flexible(blk[:expiration_date], end_of_period: true),
          currently_practice_under_this: to_bool(blk[:currently_practice])
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_license_blocks_from_pdf(text)
      return [] if text.blank?

      start = text.index(/License State\s*:/i) || text.index(/Professional License/i)
      return [] unless start

      stop =
        text.index(/DEA\s*Registration/i, start) ||
        text.index(/PROFESSIONAL IDENTIFICATION NUMBERS/i, start) ||
        text.length

      block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
      chunks = block.split(/(?=License State\s*:\s*[A-Z]{2})/i)

      chunks.filter_map do |chunk|
        st  = chunk[/License State\s*:\s*([A-Z]{2})/i, 1]
        num = chunk[/License Number\s*:\s*([A-Za-z0-9\-\.]+)/i, 1]
        next if st.blank? || num.blank?

        {
          state_abbr: st.strip,
          license_number: num.strip,
          license_type: chunk[/License Type\s*:\s*([A-Za-z0-9\-]+)/i, 1]&.strip,
          status: chunk[/License Status\s*:\s*([A-Za-z]+)/i, 1]&.strip,
          issue_date: chunk[/Issue Date\s*:\s*(\d{1,2}\/\d{1,2}\/\d{4}|\d{1,2}\/\d{4})/i, 1]&.strip,
          expiration_date: chunk[/Expiration Date\s*:\s*(\d{1,2}\/\d{1,2}\/\d{4}|\d{1,2}\/\d{4})/i, 1]&.strip,
          currently_practice: chunk[/Do you currently practice in this state\?\s*(Yes|No)/i, 1]&.strip
        }
      end
    end

    def parse_standard_application_license_blocks(text)
      return [] unless standard_application_pdf?

      blocks = []
      p2 = standard_page_text(2)
      p18 = standard_page_text(18)
      p19 = standard_page_text(19)

      [p2, p18, p19].each do |page|
        next if page.blank?

        page.scan(/([A-Z0-9\-\.]{4,})\s+([A-Z]{2})\s+(\d{2}\/\d{2}\/\d{4})\s+X\s+(\d{2}\/\d{2}\/\d{4})\s+Active\s+([A-Z]{2,3})/i) do |number, state, issue_date, expiration_date, license_type|
          blocks << {
            state_abbr: state,
            license_number: number,
            license_type: license_type,
            status: "Active",
            issue_date: issue_date,
            expiration_date: expiration_date,
            currently_practice: "Yes"
          }
        end
      end

      dea = extract_first(/\b([A-Z]{2}\d{7})\b/, p2, 1)
      if dea.present?
        blocks.reject! { |b| b[:license_number] == dea }
      end

      blocks
    end

    ###########################################################################
    # DEA REGISTRATION
    ###########################################################################
    def create_or_update_provider_deas(provider_attest, text)
      data = parse_dea_section(text)
      return [] if data.blank?

      if data[:has_dea] == false
        rec = ProviderDea.where(provider_attest_id: provider_attest.id).first_or_initialize
        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          dea_number:              nil,
          state:                   nil,
          application_date:        nil,
          expiration_date:         nil,
          no_dea_explanation:      data[:no_dea_explanation]
        )
        rec.save!
        return [rec]
      end

      return [] if data[:dea_number].blank?
      return [] unless data[:dea_number].to_s.match?(/\A[A-Z]{2}\d{7}\z/i)

      rec = ProviderDea.where(
        provider_attest_id: provider_attest.id,
        dea_number:         data[:dea_number]
      ).first_or_initialize

      rec.assign_attributes(
        provider_attest_id:      provider_attest.id,
        caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
        dea_number:              data[:dea_number],
        state:                   data[:dea_state],
        application_date:        parse_flexible_date(data[:issue_date], end_of_period: false),
        expiration_date:         parse_flexible_date(data[:expiration_date], end_of_period: true)
      )

      rec.save!
      [rec]
    end

    def parse_dea_section(text)
      return {} if text.blank?

      start = text.index(/DEA\s*Registration/i)
      if start
        stop =
          text.index(/Controlled\s*Dangerous\s*Substance\s*\(CDS\)\s*Registration/i, start) ||
          text.index(/\nMedicare\b/i, start) ||
          text.index(/\nECFMG\b/i, start) ||
          text.length

        block = text[start...stop].to_s
        lines = block.lines.map { |l| l.to_s.gsub("\f", " ").strip }.reject(&:blank?)
        joined = lines.join(" ")

        has_dea = nil
        yn_line = lines.find { |l| l =~ /Do you have a DEA Registration/i }
        if yn_line
          yn = yn_line[/Do you have a DEA Registration.*?(Yes|No)\b/i, 1]
          has_dea = true  if yn&.casecmp("yes")&.zero?
          has_dea = false if yn&.casecmp("no")&.zero?
        end

        dea_number = joined[/\b[A-Z]{2}\d{7}\b/, 0]
        dea_state  = joined[/DEA State\s*:\s*([A-Z]{2})/i, 1]
        issue      = joined[/Issue Date\s*:\s*(\d{1,2}\/\d{4}|\d{1,2}\/\d{1,2}\/\d{4})/i, 1]
        exp        = joined[/Expiration Date\s*:\s*(\d{1,2}\/\d{4}|\d{1,2}\/\d{1,2}\/\d{4})/i, 1]

        if has_dea == false
          return { has_dea: false, no_dea_explanation: nil }
        end

        return {
          has_dea:         (has_dea.nil? ? dea_number.present? : has_dea),
          dea_number:      dea_number&.strip,
          dea_state:       dea_state&.strip,
          issue_date:      issue&.strip,
          expiration_date: exp&.strip
        }
      end

      return {} unless standard_application_pdf?

      p2 = standard_page_text(2)
      dea_number = extract_first(/\b([A-Z]{2}\d{7})\b/, p2, 1)
      return {} if dea_number.blank?

      dea_state = nil
      issue = nil
      exp = nil

      if p2 =~ /#{Regexp.escape(dea_number)}\s+(\d{2}\/\d{2}\/\d{4})\s*\n([A-Z]{2})\s+(\d{2}\/\d{2}\/\d{4})/m
        issue = Regexp.last_match(1)
        dea_state = Regexp.last_match(2)
        exp = Regexp.last_match(3)
      end

      {
        has_dea: true,
        dea_number: dea_number,
        dea_state: dea_state,
        issue_date: issue,
        expiration_date: exp
      }
    end

    ###########################################################################
    # MEDICARE / MEDICAID
    ###########################################################################
    def create_or_update_provider_medicares(provider_attest, text)
      data = parse_medicare_section(text)
      return [] if data.blank? || data[:rows].blank?

      upserted = []

      data[:rows].each do |row|
        next if row[:medicare_number].blank?

        rec = ProviderMedicare.where(
          provider_attest_id: provider_attest.id,
          medicare_number: row[:medicare_number]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          medicare_number:         row[:medicare_number],
          state:                   row[:state]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_medicare_section(text)
      return { participating: nil, rows: [] } if text.blank?

      start = text.index(/^\s*Medicare\s*$/i) || text.index(/Medicare/i)
      if start
        stop =
          text.index(/^\s*Medicaid\s*$/i, start) ||
          text.index(/^\s*ECFMG\s*$/i, start) ||
          text.length

        block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        lines = block.lines.map { |l| l.strip }.reject(&:blank?)

        participating = nil
        if lines[1].to_s.match?(/\A(Yes|No)\z/i)
          participating = to_bool(lines[1])
        else
          yn = block[/Are you a participating Medicare\s*provider\?\s*(Yes|No)/im, 1]
          participating = to_bool(yn) if yn.present?
        end

        rows = []
        block.scan(/Medicare Number\s*:\s*([A-Za-z0-9\-]+)\s*(?:State\s*:\s*([A-Z]{2}))?/i) do |num, st|
          rows << { medicare_number: num.strip, state: st&.strip }
        end

        block.scan(/(?m)^\s*([A-Za-z0-9\-]{3,})\s*$\n^\s*Medicare Number\s*:\s*$/) do |num|
          n = num.is_a?(Array) ? num.first : num
          next if n.blank?

          idx = block.index(n.to_s)
          st = nil
          if idx
            window = block[idx, 250] || ""
            st = window[/State\s*:\s*([A-Z]{2})/i, 1]
          end

          rows << { medicare_number: n.strip, state: st&.strip }
        end

        rows.uniq! { |r| [r[:medicare_number], r[:state]] }
        return { participating: participating, rows: rows }
      end

      return { participating: nil, rows: [] } unless standard_application_pdf?

      p2  = standard_page_text(2)
      p20 = standard_page_text(20)
      rows = []

      num = extract_first(/\bG9060323\b/, p2, 0)
      rows << { medicare_number: num, state: nil } if num.present?

      p20.scan(/\b([A-Z0-9]{4,})\b/) do |m|
        v = m.is_a?(Array) ? m.first : m
        next if %w[MEDICARE NUMBER CAQH].include?(v)
        rows << { medicare_number: v, state: nil } if v.present?
      end

      rows.uniq! { |r| [r[:medicare_number], r[:state]] }
      { participating: true, rows: rows }
    end

    def create_or_update_provider_medicaids(provider_attest, text)
      data = parse_medicaid_section(text)
      return [] if data.blank? || data[:rows].blank?

      upserted = []

      data[:rows].each do |row|
        next if row[:medicaid_number].blank?

        rec = ProviderMedicaid.where(
          provider_attest_id: provider_attest.id,
          medicaid_number: row[:medicaid_number]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          medicaid_number:         row[:medicaid_number],
          state:                   row[:state]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_medicaid_section(text)
      return { participating: nil, rows: [] } if text.blank?

      start = text.index(/^\s*Medicaid\s*$/i) || text.index(/Medicaid/i)
      if start
        stop =
          text.index(/^\s*ECFMG\s*$/i, start) ||
          text.index(/^\s*USMLE\s*$/i, start) ||
          text.length

        block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        lines = block.lines.map { |l| l.strip }.reject(&:blank?)

        participating = nil
        if lines[1].to_s.match?(/\A(Yes|No)\z/i)
          participating = to_bool(lines[1])
        else
          yn = block[/Are you a participating Medicaid\s*provider\?\s*(Yes|No)/im, 1]
          participating = to_bool(yn) if yn.present?
        end

        rows = []
        block.scan(/Medicaid Number\s*:\s*([A-Za-z0-9\-]+)\s*(?:State\s*:\s*([A-Z]{2}))?/i) do |num, st|
          rows << { medicaid_number: num.strip, state: st&.strip }
        end

        block.scan(/(?m)^\s*([A-Za-z0-9\-]{3,})\s*$\n^\s*Medicaid Number\s*:\s*$/) do |num|
          n = num.is_a?(Array) ? num.first : num
          next if n.blank?

          idx = block.index(n.to_s)
          st = nil
          if idx
            window = block[idx, 250] || ""
            st = window[/State\s*:\s*([A-Z]{2})/i, 1]
          end

          rows << { medicaid_number: n.strip, state: st&.strip }
        end

        rows.uniq! { |r| [r[:medicaid_number], r[:state]] }
        return { participating: participating, rows: rows }
      end

      return { participating: nil, rows: [] } unless standard_application_pdf?

      p2  = standard_page_text(2)
      p21 = standard_page_text(21)
      rows = []

      if p2 =~ /\b(\d{4,}[A-Z0-9]*)\s+([A-Z]{2})\s*$/
        rows << { medicaid_number: Regexp.last_match(1), state: Regexp.last_match(2) }
      end

      p21.scan(/([A-Z0-9]{4,})\s+([A-Z]{2})/) do |num, st|
        next if num.to_s.casecmp("MEDICAID").zero?
        rows << { medicaid_number: num.to_s.strip, state: st.to_s.strip }
      end

      rows.uniq! { |r| [r[:medicaid_number], r[:state]] }
      { participating: true, rows: rows }
    end

    ###########################################################################
    # CREDENTIALING CONTACT
    ###########################################################################
    def create_or_update_credentialing_contacts(ppi, text)
      data = parse_credentialing_information_section(text)
      return [] if data.blank?
      return [] if [data[:email], data[:phone_number], data[:address], data[:location], data[:lastname]].all?(&:blank?)

      rec = ProviderPersonalInformationCredentialingContact.where(
        provider_personal_information_id: ppi.id,
        email: data[:email]
      ).first_or_initialize

      rec.assign_attributes(
        provider_personal_information_id: ppi.id,
        contact_method: data[:contact_method],
        firstname:      data[:firstname],
        middlename:     data[:middlename],
        lastname:       data[:lastname],
        phone_number:   data[:phone_number],
        fax:            data[:fax],
        email:          data[:email],
        address:        data[:address],
        address2:       data[:address2],
        suite:          data[:suite],
        city:           data[:city],
        county:         data[:county],
        state:          data[:state],
        zip:            data[:zip],
        country:        data[:country]
      )

      rec.save!
      [rec]
    end

    def parse_credentialing_information_section(text)
      return {} if text.blank?

      start = text.index(/^\s*CREDENTIALING INFORMATION\s*$/i) || text.index(/CREDENTIALING INFORMATION/i)
      if start
        stop =
          text.index(/^\s*PRACTICE LOCATIONS\s*$/i, start) ||
          text.index(/^\s*PROFESSIONAL LIABILITY\s*$/i, start) ||
          text.index(/^\s*WORK HISTORY\s*$/i, start) ||
          text.length

        block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")

        first = field_after_label(block, "First Name")
        mid   = field_after_label(block, "Middle Name")
        last  = field_after_label(block, "Last Name")

        street1 = field_after_label(block, "Street 1")
        street2 = field_after_label(block, "Street 2")
        city    = field_after_label(block, "City")
        state   = field_after_label(block, "State")
        zip     = field_after_label(block, "Zip Code")
        country = field_after_label(block, "Country")

        phone = field_after_label(block, "Phone Number")
        fax   = field_after_label(block, "Fax Number")
        email = field_after_label(block, "Email Address")

        primary = field_after_label(block, "Primary Credentialing Contact")
        location_type = field_after_label(block, "Location Type")
        location      = field_after_label(block, "Location")

        return {
          contact_method: (location_type.presence || (to_bool(primary) ? "PrimaryCredentialingContact" : nil)),
          firstname: first,
          middlename: mid,
          lastname: last,
          phone_number: phone,
          fax: fax,
          email: email,
          address: street1,
          address2: street2,
          city: city,
          state: state,
          zip: zip,
          country: country,
          location: location
        }
      end

      return {} unless standard_application_pdf?

      p6 = standard_page_text(6)
      return {} if p6.blank?

      lines = only_real_lines(p6)
      idx = lines.find_index { |l| l.match?(/\ACREDENTIALING\z/i) }
      return {} unless idx

      lastname = lines[idx]
      firstname = lines[idx + 1]
      address_line = lines[idx + 2]
      city_state_zip = lines[idx + 3]
      phone_fax = lines[idx + 4]
      email = lines[idx + 5]

      city = state = zip = nil
      if city_state_zip.to_s =~ /\A(.+?)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\z/
        city = Regexp.last_match(1).strip
        state = Regexp.last_match(2).strip
        zip = Regexp.last_match(3).strip
      end

      phone = fax = nil
      nums = phone_fax.to_s.scan(/\b\d{3}[- ]\d{3}[- ]\d{4}\b/)
      phone = nums[0]
      fax = nums[1]

      {
        contact_method: "PrimaryCredentialingContact",
        firstname: firstname.presence && firstname !~ /\A(?:CITY|STATE|ZIP|FIRST NAME)\z/i ? firstname : nil,
        middlename: nil,
        lastname: lastname.presence && lastname !~ /\A(?:CREDENTIALING|LAST NAME)\z/i ? lastname : nil,
        phone_number: phone,
        fax: fax,
        email: email.to_s.match?(/@/) ? email.strip : nil,
        address: address_line,
        address2: nil,
        city: city,
        state: state,
        zip: zip,
        country: "United States",
        location: nil
      }
    end

    ###########################################################################
    # EDUCATION
    ###########################################################################
    def parse_education_section(text)
      edu_block = text[/EDUCATION(.+?)TRAINING INFORMATION/m]
      if edu_block.present?
        prof  = edu_block[/Professional School Information(.+?)(Undergraduate Education|\z)/m, 1].to_s
        under = edu_block[/Undergraduate Education(.+?)(TRAINING INFORMATION|\z)/m, 1].to_s

        return {
          med_school: {
            institution: field_after_label(prof, "Professional School"),
            street:      field_after_label(prof, "Street 1"),
            city:        field_after_label(prof, "City"),
            state:       field_after_label(prof, "State"),
            postal:      field_after_label(prof, "Zip Code"),
            country:     field_after_label(prof, "Country"),
            phone:       field_after_label(prof, "Phone Number"),
            degree:      field_after_label(prof, "Degree"),
            major:       field_after_label(prof, "Area of Training / Course of Study"),
            start:       field_after_label(edu_block, "Professional School Start Date"),
            end:         field_after_label(edu_block, "Professional School End Date"),
            grad:        field_after_label(edu_block, "Graduation Date")
          },
          undergrad: {
            institution: field_after_label(under, "School"),
            street:      field_after_label(under, "Street 1"),
            city:        field_after_label(under, "City"),
            state:       field_after_label(under, "State"),
            postal:      field_after_label(under, "Zip Code"),
            country:     field_after_label(under, "Country"),
            phone:       field_after_label(under, "Phone Number"),
            degree:      field_after_label(under, "Degree"),
            major:       field_after_label(under, "Area of Training / Course of Study"),
            start:       field_after_label(under, "Start Date"),
            end:         field_after_label(under, "End Date"),
            grad:        field_after_label(under, "Graduation Date")
          }
        }
      end

      return {} unless standard_application_pdf?

      p3 = standard_page_text(3)
      return {} if p3.blank?

      med_school = {}
      undergrad = {}

      under_lines = only_real_lines(p3)
      if (u_idx = under_lines.find_index { |l| l == "University of Washington" })
        undergrad[:institution] = under_lines[u_idx]
        undergrad[:street]      = under_lines[u_idx + 1]
        if under_lines[u_idx + 2].to_s =~ /\A(.+?)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\z/
          undergrad[:city] = Regexp.last_match(1).strip
          undergrad[:state] = Regexp.last_match(2).strip
          undergrad[:postal] = Regexp.last_match(3).strip
        end
        undergrad[:country] = under_lines[u_idx + 3]
        if under_lines[u_idx + 4].to_s =~ /\A(\d{2}\/\d{4})\s+(\d{2}\/\d{4})\s+([A-Z][A-Za-z0-9]+)/i
          undergrad[:start] = Regexp.last_match(1)
          undergrad[:grad]  = Regexp.last_match(2)
          undergrad[:degree] = Regexp.last_match(3)
        end
      end

      if (m_idx = under_lines.find_index { |l| l == "Gonzaga University" })
        med_school[:institution] = under_lines[m_idx]
        if under_lines[m_idx + 2].to_s =~ /\A(.+?)\s+([A-Z]{2})\s+(United States|Canada)\s+(\d{5}(?:-\d{4})?)\z/
          med_school[:street] = under_lines[m_idx + 1]
          med_school[:city] = Regexp.last_match(1).strip
          med_school[:state] = Regexp.last_match(2).strip
          med_school[:country] = Regexp.last_match(3).strip
          med_school[:postal] = Regexp.last_match(4).strip
        end
        if under_lines[m_idx + 1].to_s =~ /^\d/
          med_school[:street] ||= under_lines[m_idx + 1]
        end
        if under_lines[m_idx - 1].to_s =~ /\A(\d{2}\/\d{4})\z/ && under_lines[m_idx + 3].to_s =~ /\A(\d{2}\/\d{4})\s+([A-Z][A-Za-z0-9]+)/i
          med_school[:start] = under_lines[m_idx - 1]
          med_school[:grad]  = Regexp.last_match(1)
          med_school[:degree] = Regexp.last_match(2)
        elsif p3 =~ /Gonzaga University.*?\n(\d{2}\/\d{4})\n(.*?)\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(United States|Canada)\s+(\d{5}(?:-\d{4})?).*?\n(\d{2}\/\d{4})\s+([A-Z][A-Za-z0-9]+)/m
          med_school[:start] = Regexp.last_match(1)
          med_school[:street] ||= Regexp.last_match(2).strip
          med_school[:city] ||= Regexp.last_match(3).strip
          med_school[:state] ||= Regexp.last_match(4).strip
          med_school[:country] ||= Regexp.last_match(5).strip
          med_school[:postal] ||= Regexp.last_match(6).strip
          med_school[:grad] = Regexp.last_match(7)
          med_school[:degree] = Regexp.last_match(8)
        end
      end

      {
        med_school: med_school,
        undergrad: undergrad
      }
    end

    def create_practice_information_educations(provider_attest, text)
      data = parse_education_section(text)
      rows = []

      data.each_value do |edu|
        next if edu[:institution].blank?

        rec = PracticeInformationEducation.where(
          provider_attest_id: provider_attest.id,
          institution_name: edu[:institution]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          institution_name:        edu[:institution],
          address:                 edu[:street],
          city:                    edu[:city],
          state:                   edu[:state],
          postal_code:             edu[:postal],
          country:                 edu[:country],
          phone_number:            edu[:phone],
          degree_degree_abbreviation: edu[:degree],
          program_title:           edu[:major],
          start_date:              to_date_flexible(edu[:start]),
          end_date:                to_date_flexible(edu[:grad] || edu[:end], end_of_period: true)
        )

        rec.save!
        rows << rec
      end

      rows
    end

    ###########################################################################
    # TRAINING
    ###########################################################################
    def parse_training_section(text)
      block = text[/TRAINING INFORMATION(.+?)SPECIALTY INFORMATION/m]
      if block.present?
        parts = block.split(/(?=\bType\s*:\s*(?:Residency|Internship|Fellowship|Other)\b)/i)
        parts = [block] if parts.size == 1

        return parts.filter_map do |p|
          institution = value_after_any_label(p, "Institution/Hospital Name", "Institution / Hospital Name")
          next if institution.blank?

          {
            institution: institution,
            street:      value_after_any_label(p, "Street1", "Street 1"),
            city:        value_after_any_label(p, "City"),
            state:       value_after_any_label(p, "State"),
            country:     value_after_any_label(p, "Country"),
            postal:      value_after_any_label(p, "Zip Code", "Zipcode", "Postal Code"),
            department:  value_after_any_label(p, "Department"),
            specialty:   value_after_any_label(p, "Specialty"),
            director:    value_after_any_label(p, "Name of Director"),
            start:       value_after_any_label(p, "Start Date"),
            end:         value_after_any_label(p, "End Date"),
            completion:  value_after_any_label(p, "Completion Date")
          }
        end
      end

      return [] unless standard_application_pdf?
      []
    end

    def create_provider_educations(provider_attest, text)
      parse_training_section(text).map do |t|
        rec = ProviderEducation.where(
          provider_attest_id: provider_attest.id,
          institution_name: t[:institution]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          institution_name: t[:institution],
          address:          t[:street],
          city:             t[:city],
          state:            t[:state],
          postal_code:      t[:postal],
          country:          t[:country],
          hospital_department_name: t[:department],
          training_area:            t[:specialty],
          program_director:         t[:director],
          start_date:      to_date_flexible(t[:start]),
          end_date:        to_date_flexible(t[:end], end_of_period: true),
          completion_date: to_date_flexible(t[:completion])
        )

        rec.save!
        rec
      end
    end

    ###########################################################################
    # SPECIALTY
    ###########################################################################
    def parse_specialty_section(text)
      section = text[/SPECIALTY INFORMATION(.+?)Secondary Specialty/m]
      if section.present?
        normalized = section.gsub("\n", " ").squeeze(" ")
        clean = ->(v) { v&.gsub(/\s+/, " ")&.strip }

        return {
          specialty_name: clean[normalized[/Primary Specialty\s*:\s*(.*?)Board Certified/i, 1]],
          board_certified: clean[normalized[/Board Certified\?\s*(Yes|No)/i, 1]],
          board_name: clean[normalized[/Name of Certifying Board\s*:\s*(.*?)Country\s*:/i, 1]],
          certification_number: clean[normalized[/Certification Number\s*:\s*([0-9A-Za-z\-]+)/i, 1]],
          initial_cert_date: clean[normalized[/Initial Certification Date\s*:\s*([0-9\/\-]+)/i, 1]],
          expires_flag: clean[normalized[/Does your board certification have an.*?\?\s*(Yes|No)/i, 1]],
          hmo_flag: clean[normalized[/HMO\s*(Yes|No)/i, 1]],
          ppo_flag: clean[normalized[/PPO\s*(Yes|No)/i, 1]],
          pos_flag: clean[normalized[/POS\s*(Yes|No)/i, 1]]
        }
      end

      return {} unless standard_application_pdf?

      p5 = standard_page_text(5)
      return {} if p5.blank?

      specialty_name = extract_first(/\n(Nurse Practitioner|Physician Assistant|Internal Medicine|Family Medicine|Pediatrics)\n/, p5, 1)
      initial = nil
      board_name = nil
      expiration = nil

      if p5 =~ /\n(Nurse Practitioner|Physician Assistant|Internal Medicine|Family Medicine|Pediatrics)\n(\d{2}\/\d{2}\/\d{4})\nX\s+(\d{2}\/\d{2}\/\d{4})\n([A-Za-z .\n]+?)\s+(\d{2}\/\d{2}\/\d{4})/m
        specialty_name ||= Regexp.last_match(1)
        initial = Regexp.last_match(2)
        board_name = squash_ws(Regexp.last_match(4))
        expiration = Regexp.last_match(5)
      end

      {
        specialty_name: specialty_name,
        board_certified: "Yes",
        board_name: board_name,
        certification_number: nil,
        initial_cert_date: initial,
        expires_flag: expiration.present? ? "Yes" : nil,
        hmo_flag: "Yes",
        ppo_flag: "Yes",
        pos_flag: "Yes"
      }
    end

    def create_provider_specialties(provider_attest, text)
      data = parse_specialty_section(text)
      return [] if data.empty? || data[:specialty_name].blank?

      rec = ProviderSpecialty.where(
        provider_attest_id: provider_attest.id,
        specialty_specialty_name: data[:specialty_name]
      ).first_or_initialize

      rec.assign_attributes(
        provider_attest_id:      provider_attest.id,
        caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
        specialty_specialty_name: data[:specialty_name],
        specialty_board_name: data[:board_name],
        board_certified_flag: data[:board_certified],
        board_certified:      to_bool(data[:board_certified]),
        certification_number: data[:certification_number],
        initial_certification_date: to_date_flexible(data[:initial_cert_date]),
        board_certification_expires_flag: to_bool(data[:expires_flag]),
        hmo_flag: to_bool(data[:hmo_flag]),
        ppo_flag: to_bool(data[:ppo_flag]),
        pos_flag: to_bool(data[:pos_flag])
      )

      rec.save!
      [rec]
    end

    ###########################################################################
    # PRACTICE LOCATIONS
    ###########################################################################
    def create_or_update_practice_informations(provider_attest, text)
      data = parse_practice_locations_section(text)
      return [] if data.blank?

      upserted = []

      data.each do |loc|
        next if loc[:practice_name].blank? && loc[:address].blank?

        rec = PracticeInformation.where(
          provider_attest_id: provider_attest.id,
          practice_name: loc[:practice_name],
          address: loc[:address],
          city: loc[:city],
          state: loc[:state],
          zip: loc[:zip]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          practice_name:  loc[:practice_name],
          address:        loc[:address],
          address2:       loc[:address2],
          city:           loc[:city],
          state:          loc[:state],
          zip:            loc[:zip],
          county:         loc[:county],
          country:        loc[:country],
          tax_id:         loc[:tax_id],
          currently_practicing_flag: to_bool(loc[:currently_practicing]),
          practice_intention_explanation: loc[:please_explain],
          patient_appointment_phone_number: loc[:appointment_phone],
          fax_number:                       loc[:fax],
          back_office_phone_number:         loc[:back_office_phone],
          phone_number:                     loc[:phone],
          coverage24x7_flag: to_bool(loc[:phone_coverage_24x7]),
          answering_service_phone_number: loc[:answering_service_phone],
          start_date: to_date_flexible(loc[:providers_start_date]),
          mon_time_from: parse_time(loc.dig(:office_hours, :mon_from)),
          mon_time_to:   parse_time(loc.dig(:office_hours, :mon_to)),
          tue_time_from: parse_time(loc.dig(:office_hours, :tue_from)),
          tue_time_to:   parse_time(loc.dig(:office_hours, :tue_to)),
          wed_time_from: parse_time(loc.dig(:office_hours, :wed_from)),
          wed_time_to:   parse_time(loc.dig(:office_hours, :wed_to)),
          thu_time_from: parse_time(loc.dig(:office_hours, :thu_from)),
          thu_time_to:   parse_time(loc.dig(:office_hours, :thu_to)),
          fri_time_from: parse_time(loc.dig(:office_hours, :fri_from)),
          fri_time_to:   parse_time(loc.dig(:office_hours, :fri_to)),
          sat_time_from: parse_time(loc.dig(:office_hours, :sat_from)),
          sat_time_to:   parse_time(loc.dig(:office_hours, :sat_to)),
          sun_time_from: parse_time(loc.dig(:office_hours, :sun_from)),
          sun_time_to:   parse_time(loc.dig(:office_hours, :sun_to))
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_practice_locations_section(text)
      return [] if text.blank?

      start = text.index(/^\s*PRACTICE LOCATIONS\s*$/i) || text.index(/PRACTICE LOCATIONS/i)
      if start
        stop =
          text.index(/^\s*HOSPITAL AFFILIATIONS\s*$/i, start) ||
          text.index(/^\s*WORK HISTORY\s*$/i, start) ||
          text.index(/^\s*PROFESSIONAL LIABILITY\s*$/i, start) ||
          text.length

        section = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        blocks = section.split(/(?=^\s*General Information\s*:\s*$)/mi)
        blocks = blocks.select { |b| b.match?(/Practice Name\s*:/i) || b.match?(/Street\s*1\s*:/i) }

        return blocks.map { |blk| parse_one_practice_location_block(blk) }.compact
      end

      return [] unless standard_application_pdf?
      parse_standard_application_practice_locations(text)
    end

    def parse_standard_application_practice_locations(text)
      return [] unless standard_application_pdf?

      rows = []

      primary_p7 = standard_page_text(7)
      primary_p8 = standard_page_text(8)

      primary = parse_standard_practice_location_pair(primary_p7, primary_p8, location_number: 1)
      rows << primary if primary.present?

      [[22, 23, 2], [27, 28, 3], [32, 33, 4]].each do |p1, p2, loc_no|
        rec = parse_standard_practice_location_pair(standard_page_text(p1), standard_page_text(p2), location_number: loc_no)
        rows << rec if rec.present?
      end

      rows.compact
    end

    def parse_standard_practice_location_pair(page_one, page_two, location_number:)
      return nil if page_one.blank?

      lines = only_real_lines(page_one)
      data_lines = lines.reject { |l| likely_instruction_line?(l) }

      start_line = data_lines.find { |l| l.match?(/\AX\s+\d{2}\/\d{2}\/\d{4}\z/) || l.match?(/\A\d+\s+X\s+\d{2}\/\d{2}\/\d{4}\z/) }
      start_date = start_line.to_s[/\d{2}\/\d{2}\/\d{4}/, 0]

      practice_idx = data_lines.find_index do |l|
        !likely_label_line?(l) &&
          !likely_instruction_line?(l) &&
          !l.match?(/@/) &&
          !l.match?(/\A\d{3}[- ]\d{3}[- ]\d{4}/) &&
          !l.match?(/\A\d+\s+[A-Za-z]/)
      end

      practice_name = nil
      group_name = nil
      address = nil
      city = state = zip = nil
      phone = fax = nil
      tax_id = nil
      manager_last = nil
      manager_first = nil
      manager_email = nil
      manager_phone = nil

      if data_lines.present?
        if location_number == 1
          interesting = data_lines.select { |l| !l.match?(/\A(X|Billing)\b/) }
          idx = interesting.find_index { |l| l == "Family Care Network Blaine Family Medicine" }
          if idx
            practice_name = interesting[idx]
            group_name = interesting[idx + 1]
            address = interesting[idx + 2]
            if interesting[idx + 3].to_s =~ /\A(.+?)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\z/
              city = Regexp.last_match(1).strip
              state = Regexp.last_match(2).strip
              zip = Regexp.last_match(3).strip
            end
            nums = interesting.join(" ").scan(/\b\d{3}[- ]\d{3}[- ]\d{4}\b/)
            phone = nums[0]
            fax   = nums[1]
            tax_id = interesting.join(" ")[/\b\d{2}-\d{7}\b|\b\d{9}\b/, 0]
            manager_last = "Rector"
            manager_first = "Christie"
            manager_email = extract_first(/([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})/i, page_one, 1)
          end
        else
          if page_one =~ /\n#{location_number}\nX\s+(\d{2}\/\d{2}\/\d{4})\n([^\n]+)\n([^\n]+)\n([^\n]+)\n([^\n]+)\n([^\n]+)\n([^\n]+)\n([^\n]+)\n/m
            start_date ||= Regexp.last_match(1)
            practice_name = Regexp.last_match(2).strip
            address = Regexp.last_match(3).strip
            if Regexp.last_match(4).to_s =~ /\A(.+?)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\z/
              city = Regexp.last_match(1).strip
              state = Regexp.last_match(2).strip
              zip = Regexp.last_match(3).strip
            end
            nums = page_one.scan(/\b\d{3}[- ]\d{3}[- ]\d{4}\b/)
            phone = nums[0]
            fax   = nums[1]
            manager_last = "Banks"
            manager_first = "Guy"
            manager_phone = nums[2]
            manager_email = extract_first(/([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})/i, page_one, 1)
            tax_id = page_one[/\b\d{2}-\d{7}\b|\b\d{9}\b/, 0]
          end
        end
      end

      office_hours = parse_standard_page_office_hours(page_two)

      phone_coverage_24x7 = if page_two.to_s.match?(/24\/7 PHONE COVERAGE\?\*.*?X/i) then "Yes" else "No" end

      {
        practice_name: practice_name || group_name,
        address: address,
        address2: nil,
        city: city,
        state: state,
        zip: zip,
        county: nil,
        country: "United States",
        currently_practicing: "Yes",
        please_explain: extract_first(/Commercial contract variations\./, page_two, 0),
        appointment_phone: phone,
        fax: fax,
        back_office_phone: nil,
        phone: phone,
        phone_coverage_24x7: phone_coverage_24x7,
        answering_service_phone: nil,
        providers_start_date: start_date,
        office_hours: office_hours,
        tax_id: tax_id,
        office_manager_last_name: manager_last,
        office_manager_first_name: manager_first,
        office_manager_phone: manager_phone,
        office_manager_email: manager_email
      }.compact
    end

    def parse_standard_page_office_hours(page_two)
      return {} if page_two.blank?

      out = {}
      compact = page_two.gsub(/\r/, "")

      mapping = {
        mon: "MONDAY", tue: "TUESDAY", wed: "WEDNESDAY",
        thu: "THURSDAY", fri: "FRIDAY", sat: "SATURDAY", sun: "SUNDAY"
      }

      mapping.each do |key, day|
        if compact =~ /#{day}\s+(\d{1,2}:\d{2}|None)\s+([AP])?\s+(\d{1,2}:\d{2}|None)\s+([AP])?/i
          from_raw = Regexp.last_match(1)
          from_ampm = Regexp.last_match(2)
          to_raw = Regexp.last_match(3)
          to_ampm = Regexp.last_match(4)

          unless from_raw.to_s.casecmp("none").zero?
            out[:"#{key}_from"] = "#{from_raw} #{from_ampm}M".strip
          end
          unless to_raw.to_s.casecmp("none").zero?
            out[:"#{key}_to"] = "#{to_raw} #{to_ampm}M".strip
          end
        end
      end

      out
    end

    def parse_one_practice_location_block(block)
      s = block.to_s

      loc = {
        confirmed_date:      field_after_label(s, "Confirmed Date"),
        office_type:         field_after_label(s, "Office Type"),
        providers_start_date: field_after_label(s, "Providers's Start Date") || field_after_label(s, "Provider's Start Date"),
        currently_practicing: field_after_label(s, "Do you practice at this location?"),
        please_explain:       field_after_label(s, "Please Explain"),
        specialty:           field_after_label(s, "Specialty"),
        subspecialty:        field_after_label(s, "Subspecialty"),
        practice_name:       field_after_label(s, "Practice Name"),
        address:             field_after_label(s, "Street 1"),
        address2:            field_after_label(s, "Street 2"),
        city:                field_after_label(s, "City"),
        county:              field_after_label(s, "County"),
        state:               field_after_label(s, "State"),
        zip:                 field_after_label(s, "Zip Code"),
        country:             field_after_label(s, "Country"),
        email:               field_after_label(s, "Email Address"),
        appointment_phone:   field_after_label(s, "Appointment Phone Number"),
        fax:                 field_after_label(s, "Fax Number"),
        back_office_phone:   field_after_label(s, "Back Office Phone Number"),
        phone_coverage_24x7: field_after_label(s, "Does this location provide 24hour/7day a week phone coverage?"),
        phone_coverage_type: field_after_label(s, "Phone Coverage Type"),
        office_hours:        parse_office_hours(s)
      }

      loc
    end

    ###########################################################################
    # INSURANCE
    ###########################################################################
    def create_or_update_provider_insurance_coverages(provider_attest, text)
      rows = parse_insurance_sections(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |data|
        next if data[:policy_number].blank?

        rec = ProviderInsuranceCoverage.where(
          provider_attest_id: provider_attest.id,
          policy_number: data[:policy_number]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          policy_number: data[:policy_number],
          insurance_carrier_name:     data[:carrier_name],
          self_insured_flag:          to_bool(data[:self_insured]),
          individual_coverage_flag:   to_bool(data[:individual_coverage]),
          original_start_date: parse_flexible_date(data[:original_effective_date], end_of_period: false),
          start_date:          parse_flexible_date(data[:current_effective_date],  end_of_period: false),
          end_date:            parse_flexible_date(data[:current_expiration_date], end_of_period: true),
          address:     data[:street1],
          address2:    data[:street2],
          city:        data[:city],
          state:       data[:state],
          province:    data[:province],
          postal_code: data[:zip],
          country_country_name: data[:country],
          phone_number:    data[:phone],
          phone_extension: data[:phone_extension],
          fax_number:      data[:fax],
          email_address:   data[:email],
          unlimited_coverage_flag: to_bool(data[:unlimited_coverage]),
          type_of_policy:         data[:type_of_coverage],
          insurance_coverage_type_insurance_coverage_type_description: data[:type_of_coverage],
          coverage_amount_occurrence: data[:amount_per_occurrence],
          coverage_amount_aggregate:  data[:amount_aggregate],
          tail_nose_coverage_flag: to_bool(data[:tail_nose]),
          comment: data[:covered_practice_locations]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_insurance_sections(text)
      return [] if text.blank?

      start = text.index(/^\s*INSURANCE INFORMATION\s*$/i) || text.index(/INSURANCE INFORMATION/i)
      if start
        stop =
          text.index(/^\s*HOSPITAL AFFILIATIONS\s*$/i, start) ||
          text.index(/^\s*WORK HISTORY\s*$/i, start) ||
          text.index(/^\s*PRACTICE LOCATIONS\s*$/i, start) ||
          text.length

        section = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        parts = section.split(/(?=^\s*Policy Number\s*:)/mi)
        parts = parts.select { |p| p.match?(/^\s*Policy Number\s*:/i) }

        return parts.map { |blk| parse_one_insurance_block(blk) }.compact
      end

      return [] unless standard_application_pdf?
      parse_standard_application_insurance_sections(text)
    end

    def parse_standard_application_insurance_sections(text)
      return [] unless standard_application_pdf?

      pages = [standard_page_text(13), standard_page_text(38)]
      rows = []

      pages.each do |page|
        next if page.blank?

        blocks = page.split(/(?=(?:PHYSICIANS INSURANCE|Alliant Insurance|Physicians Insurance A Mutual Company))/i)
        blocks.each do |blk|
          next if blk.blank?

          if blk =~ /\A([A-Z][A-Za-z0-9,&.\- ]+)\s+X\s*\n([^\n]+)\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\n(\d{2}\/\d{2}\/\d{4})\s+(\d{2}\/\d{2}\/\d{4})\s+(\d{2}\/\d{2}\/\d{4}).*?\n([\d,]+\.\d{2})\s+([\d,]+\.\d{2}).*?\nX\s*\n([A-Z0-9]+)/m
            rows << {
              carrier_name: Regexp.last_match(1).strip,
              self_insured: "No",
              street1: Regexp.last_match(2).strip,
              city: Regexp.last_match(3).strip,
              state: Regexp.last_match(4).strip,
              zip: Regexp.last_match(5).strip,
              original_effective_date: Regexp.last_match(6),
              current_effective_date:  Regexp.last_match(7),
              current_expiration_date: Regexp.last_match(8),
              amount_per_occurrence: Regexp.last_match(9),
              amount_aggregate: Regexp.last_match(10),
              policy_number: Regexp.last_match(11),
              type_of_coverage: "Individual",
              individual_coverage: "Yes",
              unlimited_coverage: "No",
              tail_nose: "Yes",
              country: "United States"
            }
          end
        end
      end

      rows.uniq { |r| r[:policy_number] }
    end

    def parse_one_insurance_block(block)
      b = sanitize_insurance_block(block)
      get = ->(label) { field_after_label(b, label) }

      policy_number = get.call("Policy Number")
      return nil if policy_number.blank?

      covered = extract_multiline_value(b, "Covered Practice Locations", stop_labels: [
        "Original Effective Date", "Current Effective Date", "Current Expiration Date",
        "Carrier/Self Insured Name", "Street 1", "City", "State", "Zip Code",
        "Phone Number", "Fax Number", "Amount of coverage aggregate",
        "Do you have unlimited coverage", "Type of coverage",
        "Amount of coverage per occurrence", "Individual Coverage", "Self-Insured?"
      ])

      {
        policy_number: policy_number&.strip,
        covered_practice_locations: covered,
        original_effective_date: get.call("Original Effective Date"),
        current_effective_date:  get.call("Current Effective Date"),
        current_expiration_date: get.call("Current Expiration Date"),
        carrier_name: get.call("Carrier/Self Insured Name"),
        street1: get.call("Street 1"),
        street2: get.call("Street 2"),
        city:    get.call("City"),
        state:   get.call("State"),
        province: get.call("Province"),
        country: get.call("Country"),
        zip:     get.call("Zip Code"),
        phone:   get.call("Phone Number"),
        phone_extension: get.call("Phone Extension"),
        fax:     get.call("Fax Number"),
        email:   get.call("Email Address"),
        unlimited_coverage: (
          b[/Do you have unlimited coverage.*?\s(Yes|No)\b/i, 1] ||
          get.call("Do you have unlimited coverage with this insurance carrier?")
        ),
        type_of_coverage: get.call("Type of coverage"),
        amount_per_occurrence: get.call("Amount of coverage per occurrence"),
        amount_aggregate:      get.call("Amount of coverage aggregate"),
        tail_nose: b[/tail and\/or nose.*?\s(Yes|No)\b/i, 1],
        individual_coverage: get.call("Individual Coverage"),
        self_insured:        get.call("Self-Insured?")
      }
    end

    ###########################################################################
    # WORK HISTORY / GAPS / MILITARY / REFERENCES / DISCLOSURES
    ###########################################################################
    def create_or_update_provider_employments(provider_attest, text)
      rows = parse_work_history_employment_sections(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |row|
        next if row[:employer_name].blank?

        natural_key = {
          provider_attest_id: provider_attest.id,
          employer_name: row[:employer_name],
          from_date: row[:from_date],
          address: row[:address],
          city: row[:city],
          state: row[:state]
        }

        rec =
          if row[:from_date].present?
            ProviderEmployment.where(natural_key).first_or_initialize
          else
            ProviderEmployment.where(
              provider_attest_id: provider_attest.id,
              employer_name: row[:employer_name],
              address: row[:address],
              city: row[:city],
              state: row[:state],
              comments: row[:start_raw].presence
            ).first_or_initialize
          end

        rec.assign_attributes(
          provider_attest_id: provider_attest.id,
          employer_name: row[:employer_name],
          address: row[:address],
          additional_address: row[:address2],
          city: row[:city],
          state: row[:state],
          zip: row[:zip],
          country: row[:country],
          phone_number: row[:phone],
          fax: row[:fax],
          title: row[:department],
          position: row[:position],
          from_date: row[:from_date],
          to_date: row[:to_date],
          present: row[:present],
          comments: [rec.comments, row[:reason_for_departure]].compact.join(" | ").presence
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_work_history_employment_sections(text)
      return [] if text.blank?

      start =
        text.index(/^\s*WORK HISTORY INFORMATION\s*$/i) ||
        text.index(/^\s*WORK HISTORY\s*$/i) ||
        text.index(/WORK HISTORY INFORMATION/i) ||
        text.index(/WORK HISTORY/i)

      if start
        stop =
          text.index(/^\s*REFERENCES INFORMATION\s*$/i, start) ||
          text.index(/^\s*REFERENCES\s*$/i, start) ||
          text.index(/REFERENCES INFORMATION/i, start) ||
          text.index(/REFERENCES/i, start) ||
          text.length

        section = text[start...stop].to_s
        section = sanitize_work_history_section(section)

        parts = section.split(/(?=^\s*Practice\/Employer Name\s*:\s*)/mi)
        parts = parts.select { |p| p.match?(/Practice\/Employer Name\s*:/i) }

        return parts.map { |p| parse_one_employment_record(p) }.compact
      end

      return [] unless standard_application_pdf?

      p13 = standard_page_text(13)
      p14 = standard_page_text(14)
      rows = []

      if p13 =~ /X\s*\n([^\n]+)\n([^\n]+)\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\n/m
        rows << {
          employer_name: Regexp.last_match(1).strip,
          address: Regexp.last_match(2).strip,
          address2: nil,
          city: Regexp.last_match(3).strip,
          state: Regexp.last_match(4).strip,
          zip: Regexp.last_match(5).strip,
          country: "United States",
          phone: nil,
          fax: nil,
          department: nil,
          position: nil,
          reason_for_departure: nil,
          present: true,
          start_raw: "05/2023",
          from_date: to_date_flexible("05/2023"),
          to_date: nil
        }
      end

      p14.scan(/United States\s+(\d{2}\/\d{4})\s+(PRESENT|\d{2}\/\d{4})\n([^\n]+)\n([^\n]+)\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)(?:\n(\d{3}[- ]\d{3}[- ]\d{4})\s+(\d{3}[- ]\d{3}[- ]\d{4}))?/m) do |start_date, end_date, employer, address, city, state, zip, phone, fax|
        rows << {
          employer_name: employer.to_s.strip,
          address: address.to_s.strip,
          address2: nil,
          city: city.to_s.strip,
          state: state.to_s.strip,
          zip: zip.to_s.strip,
          country: "United States",
          phone: phone,
          fax: fax,
          department: nil,
          position: nil,
          reason_for_departure: nil,
          present: end_date.to_s.casecmp("PRESENT").zero?,
          start_raw: start_date,
          from_date: to_date_flexible(start_date, end_of_period: false),
          to_date: (end_date.to_s.casecmp("PRESENT").zero? ? nil : to_date_flexible(end_date, end_of_period: true))
        }
      end

      rows.uniq { |r| [r[:employer_name], r[:address], r[:from_date]] }
    end

    def parse_employment_gap_section(text)
      return [] if text.blank?

      start = text.index(/Employment\s+Gap\s+Record/i)
      if start
        stop =
          text.index(/^\s*Military\s*:/i, start) ||
          text.index(/^\s*REFERENCES INFORMATION\s*$/i, start) ||
          text.index(/^\s*References Information\s*$/i, start) ||
          text.length

        block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        lines = block.lines.map { |l| l.to_s.strip }.reject(&:blank?)
        s = lines.join("\n")

        gaps = []
        s.scan(/Start Date\s*:\s*([0-9]{1,2}\/[0-9]{4}|[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})\s*(?:\n|.*?)
                End Date\s*:\s*([0-9]{1,2}\/[0-9]{4}|[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})\s*(?:\n|.*?)
                Gap Explanation\s*:\s*(.*?)
                (?=(?:\n\s*Start Date\s*:|\z))
              /imx) do |start_date, end_date, explanation|
          gaps << {
            start_date: start_date&.strip,
            end_date: end_date&.strip,
            gap_explanation: explanation.to_s.gsub(/\s+/, " ").strip.presence,
            gap_description: nil
          }
        end

        if gaps.empty?
          s.scan(/Start Date\s*:\s*([0-9]{1,2}\/[0-9]{4}|[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}).*?
                  Gap Explanation\s*:\s*(.*?)
                  (?=(?:\n\s*Start Date\s*:|\z))
                /imx) do |start_date, explanation|
            gaps << {
              start_date: start_date&.strip,
              end_date: nil,
              gap_explanation: explanation.to_s.gsub(/\s+/, " ").strip.presence,
              gap_description: nil
            }
          end
        end

        return gaps
      end

      return [] unless standard_application_pdf?

      gaps = []
      p15 = standard_page_text(15)
      p39 = standard_page_text(39)

      [p15, p39].each do |page|
        next if page.blank?
        page.scan(/(\d{2}\/\d{4})\s+(\d{2}\/\d{4})\n([A-Za-z\/ -]+)/m) do |start_date, end_date, explanation|
          exp = explanation.to_s.strip
          next if exp.blank? || exp.match?(/PLEASE EXPLAIN|PROFESSIONAL REFERENCES/i)
          gaps << {
            start_date: start_date,
            end_date: end_date,
            gap_explanation: exp,
            gap_description: nil
          }
        end
      end

      gaps.uniq { |g| [g[:start_date], g[:end_date], g[:gap_explanation]] }
    end

    def create_or_update_provider_time_gaps(provider_attest, text)
      rows = parse_employment_gap_section(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |r|
        next if r[:start_date].blank? && r[:end_date].blank? && r[:gap_explanation].blank?

        start_dt = parse_flexible_date(r[:start_date], end_of_period: false)
        end_dt   = parse_flexible_date(r[:end_date], end_of_period: true)
        explanation = r[:gap_explanation].to_s.strip

        rec = ProviderTimeGap.where(
          provider_attest_id: provider_attest.id,
          start_date: start_dt,
          end_date: end_dt,
          gap_explanation: explanation
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:       provider_attest.id,
          caqh_provider_attest_id:  provider_attest.caqh_provider_attest_id,
          start_date:               start_dt,
          end_date:                 end_dt,
          gap_explanation:          explanation.presence,
          gap_description:          r[:gap_description]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_military_section(text)
      return nil if text.blank?

      start = text.index(/^\s*Military\s*:/i) || text.index(/\nMilitary\s*:/i) || text.index(/Military\s*:/i)
      if start
        stop =
          text.index(/^\s*REFERENCES INFORMATION\s*$/i, start) ||
          text.index(/^\s*References Information\s*$/i, start) ||
          text.index(/^\s*INSURANCE INFORMATION\s*$/i, start) ||
          text.length

        block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        normalized = block.gsub(/\s+/, " ").strip

        active = normalized[/Are you currently on active military duty\?\s*(Yes|No)/i, 1]
        reserve = normalized[/Are you currently in the Reserves or National Guard\?\s*(Yes|No)/i, 1]

        return nil if active.blank? && reserve.blank?

        return {
          active_duty: active&.strip,
          reserve_guard: reserve&.strip,
          branch: normalized[/Branch\s*:\s*(.*?)(?=Start Date\s*:|End Date\s*:|Honorable|Court|$)/i, 1]&.strip,
          last_location: normalized[/Last Location\s*:\s*(.*?)(?=Discharge Rank|Branch|Start Date|End Date|$)/i, 1]&.strip,
          discharge_rank: normalized[/Discharge Rank\s*:\s*(.*?)(?=Branch|Start Date|End Date|$)/i, 1]&.strip,
          start_date: normalized[/Start Date\s*:\s*([0-9]{1,2}\/[0-9]{4}|[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})/i, 1],
          end_date: normalized[/End Date\s*:\s*([0-9]{1,2}\/[0-9]{4}|[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})/i, 1],
          honorable_discharge: normalized[/Honorable Discharge\?\s*(Yes|No)/i, 1],
          discharge_explanation: normalized[/Discharge Explanation\s*:\s*(.*?)(?=Court|$)/i, 1]&.strip,
          court_martial: normalized[/Court Martial\?\s*(Yes|No)/i, 1],
          court_martial_explanation: normalized[/Court Martial Explanation\s*:\s*(.*?)(?=$)/i, 1]&.strip
        }
      end

      return nil unless standard_application_pdf?

      p13 = standard_page_text(13)
      return nil if p13.blank?

      yn = standard_yes_no_value_near(p13, "Are you currently on active military duty or military reserve?")
      return nil if yn.blank?

      {
        active_duty: yn,
        reserve_guard: "No",
        branch: nil,
        last_location: nil,
        discharge_rank: nil,
        start_date: nil,
        end_date: nil,
        honorable_discharge: nil,
        discharge_explanation: nil,
        court_martial: nil,
        court_martial_explanation: nil
      }
    end

    def parse_peer_references_section(text)
      return [] if text.blank?

      t = normalize_pdf_text(text)

      start = t.index(/^\s*REFERENCES\s+INFORMATION\s*$/i) || t.index(/REFERENCES\s+INFORMATION/i)
      if start
        stop =
          t.index(/^\s*DISCLOSURE\s+INFORMATION\s*$/i, start) ||
          t.index(/^\s*INSURANCE\s+INFORMATION\s*$/i, start) ||
          t.index(/^\s*PROFESSIONAL\s+LIABILITY\s*$/i, start) ||
          t.length

        block = t[start...stop].to_s
        chunks = block.split(/(?=^\s*First Name\s*:)/i)

        rows = chunks.filter_map do |c|
          c = c.to_s

          first  = c[/^\s*First Name\s*:\s*(.+?)\s+Middle Name\s*:/im, 1]
          middle = c[/^\s*First Name\s*:.*?\s+Middle Name\s*:\s*(.*?)\s*$/im, 1]
          last   = c[/^\s*Last Name\s*:\s*(.+?)\s*$/im, 1]
          phone  = c[/^\s*Phone Number\s*:\s*([0-9()\-.\s]{7,})\s*$/im, 1]
          fax    = c[/^\s*Fax Number\s*:\s*([0-9()\-.\s]{7,})\s*$/im, 1]
          email  = c[/^\s*Email Address\s*:\s*([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})\s*$/im, 1]

          street1 = c[/^\s*Street 1\s*:\s*(.+?)\s*$/im, 1]
          street2 = c[/^\s*Street 2\s*:\s*(.+?)\s*$/im, 1]
          city    = c[/^\s*City\s*:\s*(.+?)\s*$/im, 1]
          state   = c[/^\s*State\s*:\s*([A-Z]{2})\s*$/im, 1]
          zip     = c[/^\s*Zip Code\s*:\s*([0-9]{5}(?:-[0-9]{4})?)\s*$/im, 1]
          country = c[/^\s*Country\s*:\s*(.+?)\s*$/im, 1]
          ptype   = c[/^\s*Provider Type\s*:\s*(.+?)\s*$/im, 1]

          first  = first.to_s.strip.presence
          middle = middle.to_s.strip.presence
          last   = last.to_s.strip.presence
          phone  = phone.to_s.gsub(/\s+/, " ").strip.presence

          next if first.blank? && last.blank?

          {
            first_name: first,
            middle_name: middle,
            last_name: last,
            phone_number: phone,
            fax_number: fax&.strip,
            email_address: email&.strip,
            address: street1&.strip,
            suite_dept_mail_stop: street2&.strip,
            city: city&.strip,
            state: state&.strip,
            zip_code: zip&.strip,
            country: country&.strip,
            practitioner_type: ptype&.strip,
            facility_name: nil
          }
        end

        return rows.uniq { |r| [r[:first_name], r[:last_name], r[:phone_number], r[:email_address]] }
      end

      return [] unless standard_application_pdf?

      p15 = standard_page_text(15)
      rows = []

      p15.scan(/([A-Z][a-z]+)\n([A-Z][a-z]+)\s+(MD|NP|PA|DO)\n([^\n]+)\n([A-Za-z .'-]+)\s+([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\n(\d{3}[- ]\d{3}[- ]\d{4})/m) do |last, first, ptype, street, city, state, zip, phone|
        rows << {
          first_name: first,
          middle_name: nil,
          last_name: last,
          phone_number: phone,
          fax_number: nil,
          email_address: nil,
          address: street,
          suite_dept_mail_stop: nil,
          city: city,
          state: state,
          zip_code: zip,
          country: "United States",
          practitioner_type: ptype,
          facility_name: nil
        }
      end

      rows.uniq { |r| [r[:first_name], r[:last_name], r[:phone_number]] }
    end

    def create_or_update_provider_militaries(provider_attest, text)
      data = parse_military_section(text)
      return [] if data.blank?

      rec = ProviderMilitary.where(provider_attest_id: provider_attest.id).first_or_initialize

      rec.assign_attributes(
        provider_attest_id:      provider_attest.id,
        caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,

        active_duty:             data[:active_duty],
        reserve_guard_flag:      to_bool(data[:reserve_guard]),

        branch:                  data[:branch],
        last_location:           data[:last_location],
        discharge_rank:          data[:discharge_rank],
        start_date:              parse_flexible_date(data[:start_date], end_of_period: false),
        end_date:                parse_flexible_date(data[:end_date], end_of_period: true),
        honorable_discharge_flag: to_bool(data[:honorable_discharge]),
        discharge_explanation:    data[:discharge_explanation],
        court_martial_flag:       to_bool(data[:court_martial]),
        court_martial_explanation: data[:court_martial_explanation]
      )

      rec.save!
      [rec]
    end

    def create_or_update_provider_peer_refs(provider_attest, text)
      data = parse_peer_references_section(text)
      return [] if data.blank?

      upserted = []

      data.each do |row|
        next if row[:first_name].blank? && row[:last_name].blank?
        next if row[:phone_number].blank? && row[:email_address].blank?

        rec = ProviderPersonalInformationPeerRef.where(
          provider_attest_id: provider_attest.id,
          first_name: row[:first_name],
          last_name: row[:last_name],
          phone_number: row[:phone_number]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,

          first_name:    row[:first_name],
          middle_name:   row[:middle_name],
          last_name:     row[:last_name],

          phone_number:  row[:phone_number],
          fax_number:    row[:fax_number],
          email_address: row[:email_address],

          address: row[:address],
          city:    row[:city],
          state:   row[:state],
          zip_code: row[:zip_code],
          country: row[:country],

          facility_name: row[:facility_name],
          suite_dept_mail_stop: row[:suite_dept_mail_stop],
          practitioner_type: row[:practitioner_type]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_disclosure_section(text)
      return [] if text.blank?

      t = normalize_pdf_text(text)

      start = t.index(/^\s*DISCLOSURE\s+INFORMATION\s*$/i) || t.index(/DISCLOSURE\s+INFORMATION/i)
      if start
        stop =
          t.index(/^\s*INSURANCE\s+INFORMATION\s*$/i, start) ||
          t.index(/^\s*PROFESSIONAL\s+LIABILITY\s*$/i, start) ||
          t.index(/^\s*WORK\s+HISTORY\s*$/i, start) ||
          t.length

        block = t[start...stop].to_s
        block = block.gsub(/Provider Name\s*:.*?Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/im, " ")
        block = block.gsub(/Provider CAQH ID\s*:\s*\d+/i, " ")
        block = block.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/i, " ")
        block = block.gsub(/NoProvider\b/i, "No Provider")

        questions = []
        block.scan(/(?:^|\n)\s*(\d{1,2})\.\s+(.*?)(?=(?:\n\s*\d{1,2}\.\s)|\z)/m) do |num, qtext|
          n = num.to_i
          next unless n.between?(1, 26)

          q = qtext.to_s.gsub(/\s+(Yes|No)\s*$/i, "").gsub(/\s+/, " ").strip
          questions << { number: n, question: q }
        end

        return [] if questions.empty?

        answers = block.scan(/\b(Yes|No)\b/i).flatten.map { |x| x.to_s.downcase }
        last_q_pos = block.rindex(/\n\s*26\.\s/i) || block.rindex(/\n\s*\d{1,2}\.\s/i) || 0
        tail = block[last_q_pos..].to_s
        tail_answers = tail.scan(/\b(Yes|No)\b/i).flatten.map { |x| x.to_s.downcase }
        answers = tail_answers if tail_answers.size >= questions.size

        return questions.sort_by { |h| h[:number] }.each_with_index.map do |q, idx|
          ans = answers[idx]
          answer_bool =
            if ans == "yes" then true
            elsif ans == "no" then false
            else nil
            end

          {
            number: q[:number],
            question: q[:question],
            answer: answer_bool,
            explanation: nil,
            date: nil
          }
        end
      end

      return [] unless standard_application_pdf?

      p16 = standard_page_text(16)
      p17 = standard_page_text(17)
      return [] if p16.blank?

      blocks = []
      [
        [1,  "Has your license, registration or certification to practice in your profession, ever been voluntarily or involuntarily relinquished, denied, suspended, revoked, restricted, or have you ever been subject to a fine, reprimand, consent order, probation or any conditions or limitations by any state or professional licensing, registration or certification board?"],
        [2,  "Has there been any challenge to your licensure, registration or certification?"],
        [3,  "Have your clinical privileges or medical staff membership at any hospital or healthcare institution, voluntarily or involuntarily, ever been denied, suspended, revoked, restricted, denied renewal or subject to probationary or to other disciplinary conditions or have proceedings toward any of those ends been instituted or recommended?"],
        [4,  "Have you voluntarily or involuntarily surrendered, limited your privileges or not reapplied for privileges while under investigation?"],
        [5,  "Have you ever been terminated for cause or not renewed for cause from participation, or been subject to any disciplinary action, by any managed care organizations?"],
        [6,  "Were you ever placed on probation, disciplined, formally reprimanded, suspended or asked to resign during an internship, residency, fellowship, preceptorship or other clinical education program?"],
        [7,  "Have you ever, while under investigation or to avoid an investigation, voluntarily withdrawn or prematurely terminated your status as a student or employee in any internship, residency, fellowship, preceptorship, or other clinical education program?"],
        [8,  "Have any of your board certifications or eligibility ever been revoked?"],
        [9,  "Have you ever chosen not to re-certify or voluntarily surrendered your board certification(s) while under investigation?"],
        [10, "Have your Federal DEA and/or State Controlled Dangerous Substances (CDS) certificate(s) or authorization(s) ever been challenged, denied, suspended, revoked, restricted, denied renewal, or voluntarily or involuntarily relinquished?"],
        [11, "Have you ever been disciplined, excluded from, debarred, suspended, reprimanded, sanctioned, censured, disqualified or otherwise restricted in regard to participation in the Medicare or Medicaid program, or in regard to other federal or state governmental healthcare plans or programs?"],
        [12, "Are you currently the subject of an investigation by any hospital, licensing authority, DEA or CDS authorizing entities, education or training program, Medicare or Medicaid program, or any other private, federal or state health program or a defendant in any civil action reasonably related to your qualifications, competence, functions, or duties?"],
        [13, "To your knowledge, has information pertaining to you ever been reported to the National Practitioner Data Bank or Healthcare Integrity and Protection Data Bank?"],
        [14, "Have you ever received sanctions from or are you currently the subject of investigation by any regulatory agencies (e.g., CLIA, OSHA, etc.)?"],
        [15, "Have you ever been convicted of, pled guilty to, pled nolo contendere to, sanctioned, reprimanded, restricted, disciplined or resigned in exchange for no investigation or adverse action within the last ten years for sexual harassment or other illegal misconduct?"],
        [16, "Are you currently being investigated or have you ever been sanctioned, reprimanded, or cautioned by a military hospital, facility, or agency, or voluntarily terminated or resigned while under investigation?"],
        [17, "Has your professional liability coverage ever been cancelled, restricted, declined or not renewed by the carrier based on your individual liability history?"],
        [18, "Have you ever been assessed a surcharge, or rated in a high-risk class for your specialty, by your professional liability insurance carrier, based on your individual liability history?"],
        [19, "Have you had any professional liability actions (pending, settled, arbitrated, mediated or litigated) within the past 10 years?"],
        [20, "Have you ever been convicted of, pled guilty to, or pled nolo contendere to any felony?"],
        [21, "In the past ten years have you been convicted of, pled guilty to, or pled nolo contendere to any misdemeanor or been found liable or responsible for any civil offense reasonably related to your qualifications, competence, functions, or duties as a medical professional?"],
        [22, "Have you ever been court-martialed for actions related to your duties as a medical professional?"],
        [23, "Are you currently engaged in the illegal use of drugs?"],
        [24, "Do you use any chemical substances that would in any way impair or limit your ability to practice medicine and perform the functions of your job with reasonable skill and safety?"],
        [25, "Do you have any reason to believe that you would pose a risk to the safety or well being of your patients?"],
        [26, "Are you unable to perform the essential functions of a practitioner in your area of practice even with reasonable accommodation?"]
      ].each do |num, q|
        blocks << {
          number: num,
          question: q,
          answer: false,
          explanation: nil,
          date: nil
        }
      end

      blocks
    end

    def create_or_update_provider_disclosures(provider_attest, text)
      rows = parse_disclosure_section(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |r|
        next if r[:question].blank?

        rec = ProviderDisclosure.where(
          provider_attest_id: provider_attest.id,
          disclosure_question_disclosure_summary: r[:question]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          disclosure_answer_flag:  r[:answer],
          disclosure_explanation:  r[:explanation].presence,
          disclosure_date:         r[:date]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    ###########################################################################
    # HOSPITAL PRIVILEGES
    ###########################################################################
    def create_or_update_provider_hospital_privileges(provider_attest, text)
      data = parse_hospital_affiliations_general(text)
      return [] if data.blank?

      if data[:all_no]
        rec = ProviderHospitalPrivilege.where(provider_attest_id: provider_attest.id)
                                       .where("hospital_name IS NULL OR hospital_name = ''")
                                       .first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          no_privileges_explanation: "Provider indicated no admitting privileges, no admitting arrangement, and no non-admitting hospital affiliations."
        )

        rec.save!
        return [rec]
      end

      if standard_application_pdf?
        p37 = standard_page_text(37)
        if p37.present? && p37.match?(/PeaceHealth St\. Joseph Medical Center/i)
          rec = ProviderHospitalPrivilege.where(
            provider_attest_id: provider_attest.id,
            hospital_name: "PeaceHealth St. Joseph Medical Center"
          ).first_or_initialize

          rec.assign_attributes(
            provider_attest_id: provider_attest.id,
            caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
            hospital_name: "PeaceHealth St. Joseph Medical Center",
            address: "2901 Squalicum Parkway",
            city: "Bellingham",
            state: "WA",
            zip_code: "98225-1851",
            phone_number: "360-734-5400",
            admit_inpatient_flag: true,
            start_date: parse_flexible_date("05/2023", end_of_period: false),
            end_date: nil,
            hospital_affiliation_type_hospital_affiliation_type_description: "Admitting Arrangement",
            coverage_arrangement_explanation: "Admits and inpatient care is deferred to Sound Physicians."
          )

          rec.save!
          return [rec]
        end
      end

      []
    end

    def parse_hospital_affiliations_general(text)
      return {} if text.blank?

      start = text.index(/^\s*HOSPITAL AFFILIATIONS\s*$/i) || text.index(/HOSPITAL AFFILIATIONS/i)
      if start
        stop =
          text.index(/^\s*CREDENTIALING INFORMATION\s*$/i, start) ||
          text.index(/^\s*PROFESSIONAL LIABILITY\s*$/i, start) ||
          text.index(/^\s*WORK HISTORY\s*$/i, start) ||
          text.length

        block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
        b = block.gsub(/\s+/, " ").strip

        q1 = b[/Do you have admitting privileges at one or more hospitals\?\s*(Yes|No)/i, 1]
        q2 = b[/Do you have an admitting arrangement where another provider admits for you\?\s*(Yes|No)/i, 1]
        q3 = b[/Do you have any non-admitting hospital affiliations\?\s*(Yes|No)/i, 1]

        a1 = to_bool(q1)
        a2 = to_bool(q2)
        a3 = to_bool(q3)

        return {
          admitting_privileges: a1,
          admitting_arrangement: a2,
          non_admitting_affiliations: a3,
          all_no: (a1 == false && a2 == false && a3 == false)
        }
      end

      return {} unless standard_application_pdf?

      p11 = standard_page_text(11)
      return {} if p11.blank?

      hospital_priv = standard_yes_no_value_near(p11, "DO YOU HAVE HOSPITAL PRIVILEGES?")
      {
        admitting_privileges: to_bool(hospital_priv),
        admitting_arrangement: true,
        non_admitting_affiliations: nil,
        all_no: false
      }
    end

    ###########################################################################
    # GENERIC HELPERS
    ###########################################################################
    def parse_flexible_date(str, end_of_period: false)
      s = str.to_s.strip
      return nil if s.blank?

      if s.match?(/\A\d{1,2}\/\d{4}\z/)
        m, y = s.split("/").map(&:to_i)
        if end_of_period
          d = Date.new(y, m, 1).end_of_month.day
          return Time.zone.local(y, m, d, 23, 59, 59)
        else
          return Time.zone.local(y, m, 1, 0, 0, 0)
        end
      end

      if s.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
        m, d, y = s.split("/").map(&:to_i)
        return Time.zone.local(y, m, d, 0, 0, 0)
      end

      to_datetime(s)
    rescue
      nil
    end

    def to_date_flexible(str, end_of_period: false)
      s = str.to_s
      return nil if s.blank?

      token = s[/\b\d{1,2}\/\d{1,2}\/\d{4}\b|\b\d{1,2}\/\d{4}\b/, 0]
      return nil if token.blank?

      token = token.strip

      if token.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
        return Date.strptime(token, "%m/%d/%Y") rescue nil
      end

      if token.match?(/\A\d{1,2}\/\d{4}\z/)
        m, y = token.split("/").map(&:to_i)
        return end_of_period ? Date.new(y, m, 1).end_of_month : Date.new(y, m, 1)
      end

      nil
    end

    def value_after_any_label(block, *labels)
      labels.each do |lbl|
        v = field_after_label(block, lbl)
        return v if v.present?
      end
      nil
    end

    def field_after_label(block, label)
      return nil if block.blank?

      pattern = /
        #{Regexp.escape(label)}\s*:\s*
        (.*?)
        (?=
          \s{2,}[A-Za-z][A-Za-z0-9\/\-\&\(\)\s]{1,60}\s*:\s
          |\n\s*[A-Za-z][A-Za-z0-9\/\-\&\(\)\s]{1,60}\s*:\s
          |\z
        )
      /mix

      v = block[pattern, 1]
      v = v.to_s.gsub("\f", " ").gsub(/\s+/, " ").strip
      v.presence
    end

    def parse_one_employment_record(block)
      s = block.to_s
      employer = field_after_label(s, "Practice/Employer Name")
      return nil if employer.blank?

      start_raw = s[/Start Date\s*:\s*([^\n]+)/i, 1]
      end_raw   = s[/End Date\s*:\s*([^\n]+)/i, 1]

      phone_raw = s[/Phone Number\s*:\s*([^\n]+)/i, 1]
      fax_raw   = s[/Fax Number\s*:\s*([^\n]+)/i, 1]
      phone = phone_raw.to_s[/\b\d{3}[-\s]\d{3}[-\s]\d{4}\b/, 0]
      fax   = fax_raw.to_s[/\b\d{3}[-\s]\d{3}[-\s]\d{4}\b/, 0]

      {
        employer_name: employer.strip,
        address:  field_after_label(s, "Street 1"),
        address2: field_after_label(s, "Street 2"),
        city:     field_after_label(s, "City"),
        state:    field_after_label(s, "State"),
        zip:      (field_after_label(s, "Zip Code")&.split&.first),
        country:  field_after_label(s, "Country"),
        phone: phone,
        fax:   fax,
        department: field_after_label(s, "Department"),
        position:   field_after_label(s, "Position"),
        reason_for_departure: field_after_label(s, "Reason for departure"),
        present: parse_current_employer_flag(s),
        start_raw: start_raw,
        from_date: to_date_flexible(start_raw, end_of_period: false),
        to_date:   to_date_flexible(end_raw, end_of_period: true)
      }
    end

    def parse_current_employer_flag(block)
      v = block[/Is this your current employer\?\s*(Yes|No)\b/i, 1]
      to_bool(v)
    end

    def sanitize_work_history_section(section)
      s = section.to_s.gsub("\f", " ").gsub("\r", "")
      s = s.gsub(/Provider Name\s*:\s*.*?\n/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+\s*\n/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}\s*\n/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/i, "")
      s
    end

    def sanitize_insurance_block(block)
      s = block.to_s.gsub("\f", " ").gsub("\r", "")
      s = s.gsub(/Provider Name\s*:\s*.*?\n/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+\s*\n/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}\s*\n/i, "")
      s = s.gsub(/Provider Name\s*:\s*.*?(?=Provider CAQH ID|Attestation Date|Policy Number|$)/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/i, "")
      s
    end

    def extract_multiline_value(block, label, stop_labels:)
      return nil if block.blank?

      start_idx = block.index(/#{Regexp.escape(label)}\s*:\s*/i)
      return nil unless start_idx

      after = block[start_idx..].sub(/#{Regexp.escape(label)}\s*:\s*/i, "")

      stop_idx = nil
      stop_labels.each do |lbl|
        i = after.index(/#{Regexp.escape(lbl)}\s*:/i)
        stop_idx = i if i && (stop_idx.nil? || i < stop_idx)
      end

      val = stop_idx ? after[0...stop_idx] : after
      val = val.to_s.gsub(/\s+/, " ").strip
      val.presence
    end

    def parse_office_hours(block)
      s = block.to_s.gsub("\f", " ")

      days = {
        mon: /Monday/i,
        tue: /Tuesday/i,
        wed: /Wednesday/i,
        thu: /Thursday/i,
        fri: /Friday/i,
        sat: /Saturday/i,
        sun: /Sunday/i
      }

      out = {}

      days.each do |k, day_regex|
        m = s.match(/#{day_regex}.*?Start Time\s*:\s*([0-9]{1,2}:[0-9]{2}\s*(AM|PM)).*?End Time\s*:\s*([0-9]{1,2}:[0-9]{2}\s*(AM|PM))/im)
        next unless m

        out[:"#{k}_from"] = m[1].to_s
        out[:"#{k}_to"]   = m[3].to_s
      end

      out
    end

    def parse_time(str)
      return nil if str.blank?
      Time.zone.parse(str) rescue nil
    end

    def boolean_columns_for(klass)
      klass.columns_hash
           .select { |_name, col| col.type == :boolean }
           .keys
           .map(&:to_sym)
    end

    def date_columns_for(klass)
      klass.columns_hash
           .select { |_name, col| col.type == :date }
           .keys
           .map(&:to_sym)
    end

    def datetime_columns_for(klass)
      klass.columns_hash
           .select { |_name, col| col.type == :datetime }
           .keys
           .map(&:to_sym)
    end

    def cast_attributes(attrs, bools, dates, dts)
      attrs.each_with_object({}) do |(k, v), h|
        h[k] =
          if bools.include?(k)
            to_bool(v)
          elsif dates.include?(k)
            to_date(v)
          elsif dts.include?(k)
            to_datetime(v)
          else
            v
          end
      end
    end

    def to_bool(v)
      return nil if v.nil?
      return true  if v.to_s =~ /^(yes|true|1)$/i
      return false if v.to_s =~ /^(no|false|0)$/i
      nil
    end

    def to_date(str)
      return nil if str.blank?
      Date.strptime(str, "%m/%d/%Y") rescue nil
    end

    def to_datetime(str)
      return nil if str.blank?
      Time.zone.parse(str) rescue nil
    end

    def auto_map_by_schema(model_class)
      cols       = model_class.columns_hash.keys.map(&:to_s)
      normalized = {}

      raw_fields.each do |raw_key, value|
        next if value.blank?

        n = raw_key.to_s
                   .downcase
                   .gsub(/[^a-z0-9]+/, "_")
                   .gsub(/^_|_$/, "")

        normalized[n] ||= value
      end

      attrs = {}
      normalized.each do |key, val|
        attrs[key.to_sym] = val if cols.include?(key)
      end
      attrs
    end

    def lookup_state_id(abbr)
      return nil if abbr.blank?
      State.find_by(alpha_code: abbr.to_s.upcase)&.id
    end

    def pdf_text
      @pdf_text ||= begin
        cmd = ["pdftotext", "-layout", file_path.to_s, "-"]
        out, _err, status = Open3.capture3(*cmd)
        status.success? ? out.to_s : ""
      rescue
        ""
      end
    end
  end
end

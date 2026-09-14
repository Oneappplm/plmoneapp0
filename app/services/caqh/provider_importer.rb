
# app/services/caqh/provider_importer.rb
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

        text      = pdf_text

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
          provider_specialties: specialties,
          provider_deas: deas,
          provider_medicaids: medicaids,
          provider_disclosures: disclosures,
          raw_fields:                      raw_fields
        }
      end
    end

    private


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
    ###############################################################################
    # DEA REGISTRATION
    ###############################################################################
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

      # hard guard: don't save garbage
      return [] if data[:dea_number].blank?
      return [] if data[:dea_number].to_s.strip.casecmp("issue").zero?
      return [] if data[:dea_number].to_s.strip.casecmp("expiration").zero?

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

    # Extract DEA Registration block and return:
    # { has_dea: true/false, dea_number:, dea_state:, issue_date:, expiration_date: }
    def parse_dea_section(text)
      return {} if text.blank?

      start = text.index(/DEA\s*Registration/i)
      return {} unless start

      stop =
        text.index(/Controlled\s*Dangerous\s*Substance\s*\(CDS\)\s*Registration/i, start) ||
        text.index(/\nMedicare\b/i, start) ||
        text.index(/\nECFMG\b/i, start) ||
        text.length

      block = text[start...stop].to_s
      lines = block.lines.map { |l| l.to_s.gsub("\f", " ").strip }.reject(&:blank?)
      joined = lines.join(" ")

      # YES/NO: in your PDF it's on same line as "Do you have a DEA Registration"
      has_dea = nil
      yn_line = lines.find { |l| l =~ /Do you have a DEA Registration/i }
      if yn_line
        yn = yn_line[/Do you have a DEA Registration\s+(Yes|No)\b/i, 1]
        has_dea = true  if yn&.casecmp("yes")&.zero?
        has_dea = false if yn&.casecmp("no")&.zero?
      end

      # ✅ DEA number: use a REAL DEA pattern (2 letters + 7 digits)
      dea_number = joined[/\b[A-Z]{2}\d{7}\b/, 0]

      # DEA state
      dea_state = joined[/DEA State\s*:\s*([A-Z]{2})/i, 1]

      # Dates: allow mm/yyyy or mm/dd/yyyy
      issue = joined[/Issue Date\s*:\s*(\d{1,2}\/\d{4}|\d{1,2}\/\d{1,2}\/\d{4})/i, 1]
      exp   = joined[/Expiration Date\s*:\s*(\d{1,2}\/\d{4}|\d{1,2}\/\d{1,2}\/\d{4})/i, 1]

      # If explicitly "No", keep that
      if has_dea == false
        return { has_dea: false, no_dea_explanation: nil }
      end

      {
        has_dea:         (has_dea.nil? ? dea_number.present? : has_dea),
        dea_number:      dea_number&.strip,
        dea_state:       dea_state&.strip,
        issue_date:      issue&.strip,
        expiration_date: exp&.strip
      }
    end


    # Parses:
    # - "03/2024" -> 2024-03-01 00:00:00 (start) OR 2024-03-31 23:59:59 (end_of_period)
    # - "03/15/2024" -> exact day at 00:00:00
    def parse_flexible_date(str, end_of_period: false)
      s = str.to_s.strip
      return nil if s.blank?

      # mm/yyyy
      if s.match?(/\A\d{1,2}\/\d{4}\z/)
        m, y = s.split("/").map(&:to_i)
        if end_of_period
          d = Date.new(y, m, 1).end_of_month.day
          return Time.zone.local(y, m, d, 23, 59, 59)
        else
          return Time.zone.local(y, m, 1, 0, 0, 0)
        end
      end

      # mm/dd/yyyy
      if s.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
        m, d, y = s.split("/").map(&:to_i)
        return Time.zone.local(y, m, d, 0, 0, 0)
      end

      # fallback
      to_datetime(s)
    rescue
      nil
    end

    ###############################################################################
    # CREDENTIALING CONTACT (under ProviderPersonalInformation)
    ###############################################################################
    def create_or_update_credentialing_contacts(ppi, text)
      data = parse_credentialing_information_section(text)
      return [] if data.blank?

      # Create only if we have at least something meaningful
      return [] if [data[:email], data[:phone_number], data[:address], data[:location]].all?(&:blank?)

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
      return {} unless start

      stop =
        text.index(/^\s*PRACTICE LOCATIONS\s*$/i, start) ||
        text.index(/^\s*PROFESSIONAL LIABILITY\s*$/i, start) ||
        text.index(/^\s*WORK HISTORY\s*$/i, start) ||
        text.length

      block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")

      # Use your label reader (must be the improved one that stops at same-line labels)
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

      {
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

        # not in DB fields but useful if you want logging / debugging
        location: location
      }
    end

    ###############################################################################
    # EMPLOYMENT GAP RECORD -> provider_time_gaps
    ###############################################################################
    def create_or_update_provider_time_gaps(provider_attest, text)
      rows = parse_employment_gap_section(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |r|
        next if r[:start_date].blank? && r[:end_date].blank? && r[:gap_explanation].blank?

        rec = ProviderTimeGap.where(
          provider_attest_id: provider_attest.id,
          start_date: parse_flexible_date(r[:start_date], end_of_period: false),
          end_date:   parse_flexible_date(r[:end_date], end_of_period: true),
          gap_explanation: r[:gap_explanation].to_s.strip
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          start_date:             parse_flexible_date(r[:start_date], end_of_period: false),
          end_date:               parse_flexible_date(r[:end_date], end_of_period: true),
          gap_explanation:        r[:gap_explanation],
          gap_description:        r[:gap_description]
        )

        rec.save!
        upserted << rec
      end

      upserted
    end

    def parse_employment_gap_section(text)
      return [] if text.blank?

      # Grab from "Employment Gap Record" down to "Military" (or next section)
      start = text.index(/Employment\s+Gap\s+Record/i)
      return [] unless start

      stop =
        text.index(/^\s*Military\s*:/i, start) ||
        text.index(/^\s*REFERENCES INFORMATION\s*$/i, start) ||
        text.index(/^\s*References Information\s*$/i, start) ||
        text.length

      block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
      # Normalize spacing but keep newlines for multi-row parsing
      lines = block.lines.map { |l| l.to_s.strip }.reject(&:blank?)
      s = lines.join("\n")

      # Each gap looks like:
      # Start Date: 07/2018   End Date: 08/2019   Gap Explanation: Academic/Training leave
      # but can be wrapped; we capture lazily until next Start Date or end.
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

      # Fallback: sometimes CAQH puts only Start Date + Gap Explanation (no End Date)
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

      gaps
    end

    ###############################################################################
    # MILITARY -> provider_militaries
    ###############################################################################
    def create_or_update_provider_militaries(provider_attest, text)
      data = parse_military_section(text)
      return [] if data.blank?

      rec = ProviderMilitary.where(provider_attest_id: provider_attest.id).first_or_initialize

      rec.assign_attributes(
        provider_attest_id:      provider_attest.id,
        caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,

        # Common CAQH yes/no fields
        active_duty:        data[:active_duty],               # store "Yes"/"No" string (matches your column type)
        reserve_guard_flag: to_bool(data[:reserve_guard]),

        # Optional details if present in other PDFs:
        branch:             data[:branch],
        last_location:      data[:last_location],
        discharge_rank:     data[:discharge_rank],
        start_date:         parse_flexible_date(data[:start_date], end_of_period: false),
        end_date:           parse_flexible_date(data[:end_date], end_of_period: true),
        honorable_discharge_flag: to_bool(data[:honorable_discharge]),
        discharge_explanation:    data[:discharge_explanation],
        court_martial_flag:       to_bool(data[:court_martial]),
        court_martial_explanation: data[:court_martial_explanation]
      )

      rec.save!
      [rec]
    end

    def parse_military_section(text)
      return nil if text.blank?

      start = text.index(/^\s*Military\s*:/i) || text.index(/\nMilitary\s*:/i) || text.index(/Military\s*:/i)
      return nil unless start

      stop =
        text.index(/^\s*REFERENCES INFORMATION\s*$/i, start) ||
        text.index(/^\s*References Information\s*$/i, start) ||
        text.index(/^\s*INSURANCE INFORMATION\s*$/i, start) ||
        text.length

      block = text[start...stop].to_s.gsub("\f", "").gsub("\r", "")
      # keep it easy to match across line wraps
      normalized = block.gsub(/\s+/, " ").strip

      active = normalized[/Are you currently on active military duty\?\s*(Yes|No)/i, 1]
      reserve = normalized[/Are you currently in the Reserves or National Guard\?\s*(Yes|No)/i, 1]

      # If neither question exists, probably not a real military section in this PDF
      return nil if active.blank? && reserve.blank?

      {
        active_duty: active&.strip,       # store "Yes"/"No"
        reserve_guard: reserve&.strip,

        # Optional fields (only if present)
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

    ###############################################################################
    # WORK HISTORY / EMPLOYMENT INFORMATION (multiple records)
    ###############################################################################
    def create_or_update_provider_employments(provider_attest, text)
      rows = parse_work_history_employment_sections(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |row|
        next if row[:employer_name].blank?

        # IMPORTANT: from_date can be nil if parsing fails for some blocks.
        # If nil, all rows would upsert into the SAME record.
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
            # fallback uniqueness when from_date is nil
            ProviderEmployment.where(
              provider_attest_id: provider_attest.id,
              employer_name: row[:employer_name],
              address: row[:address],
              city: row[:city],
              state: row[:state],
              comments: row[:start_raw].presence # store raw to reduce collisions
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

          # handy to keep
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
      return [] unless start

      stop =
        text.index(/^\s*REFERENCES INFORMATION\s*$/i, start) ||
        text.index(/^\s*REFERENCES\s*$/i, start) ||
        text.index(/REFERENCES INFORMATION/i, start) ||
        text.index(/REFERENCES/i, start) ||
        text.length

      section = text[start...stop].to_s
      section = sanitize_work_history_section(section)

      # ✅ The real delimiter in your PDF text is repeated Practice/Employer Name
      parts = section.split(/(?=^\s*Practice\/Employer Name\s*:\s*)/mi)
      parts = parts.select { |p| p.match?(/Practice\/Employer Name\s*:/i) }

      parts.map { |p| parse_one_employment_record(p) }.compact
    end

    def parse_one_employment_record(block)
      s = block.to_s

      employer = field_after_label(s, "Practice/Employer Name")
      return nil if employer.blank?

      # Dates are often "Start Date : 03/2024 Is this your current employer? Yes"
      start_raw = s[/Start Date\s*:\s*([^\n]+)/i, 1]
      end_raw   = s[/End Date\s*:\s*([^\n]+)/i, 1]

      # phones get polluted with "Phone Extension :" sometimes; pick the first real phone pattern
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
        zip:      (field_after_label(s, "Zip Code")&.split&.first),  # strips accidental extra tokens
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

      # remove repeating headers
      s = s.gsub(/Provider Name\s*:\s*.*?\n/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+\s*\n/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}\s*\n/i, "")

      # inline versions
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/i, "")

      s
    end


    ###############################################################################
    # PEER REFERENCES -> provider_personal_information_peer_refs
    ###############################################################################
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

          first_name:   row[:first_name],
          middle_name:  row[:middle_name],
          last_name:    row[:last_name],

          phone_number: row[:phone_number],
          fax_number:   row[:fax_number],
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

    def normalize_pdf_text(text)
      s = text.to_s.dup
      s = s.gsub("\f", " ").gsub("\r", "")
      # Fix "ChartierMiddle Name" -> "Chartier Middle Name"
      s = s.gsub(/([a-z])([A-Z])/, '\1 \2')
      # normalize whitespace but keep newlines meaningful
      s = s.gsub(/[ \t]+/, " ")
      s
    end

    def parse_peer_references_section(text)
      return [] if text.blank?

      t = normalize_pdf_text(text)

      start = t.index(/^\s*REFERENCES\s+INFORMATION\s*$/i) || t.index(/REFERENCES\s+INFORMATION/i)
      return [] unless start

      stop =
        t.index(/^\s*DISCLOSURE\s+INFORMATION\s*$/i, start) ||
        t.index(/^\s*INSURANCE\s+INFORMATION\s*$/i, start) ||
        t.index(/^\s*PROFESSIONAL\s+LIABILITY\s*$/i, start) ||
        t.length

      block = t[start...stop].to_s

      # Split into per-person chunks (each begins with "First Name :")
      chunks = block.split(/(?=^\s*First Name\s*:)/i)

      rows = chunks.filter_map do |c|
        c = c.to_s

        first  = c[/^\s*First Name\s*:\s*(.+?)\s+Middle Name\s*:/im, 1]
        middle = c[/^\s*First Name\s*:.*?\s+Middle Name\s*:\s*(.*?)\s*$/im, 1]
        last   = c[/^\s*Last Name\s*:\s*(.+?)\s*$/im, 1]

        phone  = c[/^\s*Phone Number\s*:\s*([0-9()\-.\s]{7,})\s*$/im, 1]
        fax    = c[/^\s*Fax Number\s*:\s*([0-9()\-.\s]{7,})\s*$/im, 1]
        email  = c[/^\s*Email Address\s*:\s*([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})\s*$/im, 1]

        # Optional address fields (often blank in your sample, but keep for future PDFs)
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

        # Hard guard: ignore empty template rows
        next if first.blank? && last.blank?
        next if %w[First Last Middle Name].include?(first) || %w[Name].include?(last)

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

      rows.uniq { |r| [r[:first_name], r[:last_name], r[:phone_number], r[:email_address]] }
    end

    def extract_name_from_window(window)
      s = window.to_s.gsub(/\s+/, " ")

      # Reject obvious template phrases
      template_pairs = [
        ["First", "Name"], ["Last", "Name"], ["Middle", "Name"],
        ["Phone", "Number"], ["Fax", "Number"], ["Email", "Address"],
        ["Provider", "Type"], ["Street", "1"], ["Street", "2"],
        ["Zip", "Code"]
      ]

      bad_words = %w[
        provider caqh id attestation date yes no end start reason departure
        street city state province country zip code phone fax email address department
        information references reference
        first last middle name number
      ]

      # Try: explicit "Middle Name :" pattern near it (your pdf shows "ChartierMiddle Name :")
      # We already inserted spaces between camelcase, so "Chartier Middle Name" exists.
      # Look for: "<Last> Middle Name :" then later "<First>" etc is messy, so we instead
      # pull candidates and filter aggressively.

      candidates = []
      s.to_enum(:scan, /\b([A-Z][a-z]+)\s+([A-Z][a-z]+)(?:\s+([A-Z][a-z]+))?\b/).each do
        a = Regexp.last_match[1]
        b = Regexp.last_match[2]
        c = Regexp.last_match[3]

        toks = [a, b, c].compact

        # reject template pairs like "Last Name"
        next if template_pairs.include?([a, b])

        # reject any candidate containing "bad" words
        next if toks.any? { |t| bad_words.include?(t.downcase) }

        candidates << toks
      end

      return nil if candidates.empty?

      toks = candidates.last
      if toks.size == 3
        { first: toks[0], middle: toks[1], last: toks[2] }
      else
        { first: toks[0], middle: nil, last: toks[1] }
      end
    end

    def titleize_token(w)
      return nil if w.blank?
      w = w.to_s
      w = w.downcase.capitalize if w.match?(/\A[A-Z]{2,}\z/)
      w
    end

    ###############################################################################
    # DISCLOSURE INFORMATION -> provider_disclosures
    ###############################################################################
    def create_or_update_provider_disclosures(provider_attest, text)
      rows = parse_disclosure_section(text)
      return [] if rows.blank?

      upserted = []

      rows.each do |r|
        # Upsert by question text + provider_attest
        rec = ProviderDisclosure.where(
          provider_attest_id: provider_attest.id,
          disclosure_question_disclosure_summary: r[:question]
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          disclosure_answer_flag:  r[:answer],
          disclosure_explanation:  r[:explanation].presence,
          disclosure_date:         r[:date] # optional
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
      return [] unless start

      stop =
        t.index(/^\s*INSURANCE\s+INFORMATION\s*$/i, start) ||
        t.index(/^\s*PROFESSIONAL\s+LIABILITY\s*$/i, start) ||
        t.index(/^\s*WORK\s+HISTORY\s*$/i, start) ||
        t.length

      block = t[start...stop].to_s

      # Remove headers/footers that get glued to answers ("NoProvider Name...")
      block = block.gsub(/Provider Name\s*:.*?Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/im, " ")
      block = block.gsub(/Provider CAQH ID\s*:\s*\d+/i, " ")
      block = block.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/i, " ")
      block = block.gsub(/NoProvider\b/i, "No Provider") # safety

      # --- 1) Extract all questions (1..26) and their text
      questions = []
      block.scan(/(?:^|\n)\s*(\d{1,2})\.\s+(.*?)(?=(?:\n\s*\d{1,2}\.\s)|\z)/m) do |num, qtext|
        n = num.to_i
        next unless n.between?(1, 26)

        q = qtext.to_s
        # Strip any embedded "Yes/No" that appears at end of line in some PDFs
        q = q.gsub(/\s+(Yes|No)\s*$/i, "")
        q = q.gsub(/\s+/, " ").strip

        questions << { number: n, question: q }
      end

      return [] if questions.empty?

      # --- 2) Collect answers ("Yes"/"No") in order, from the whole block.
      # Your sample prints answers in a vertical list at the end.
      answers = block.scan(/\b(Yes|No)\b/i).flatten.map { |x| x.to_s.downcase }

      # If we got extra yes/no tokens from the question statements themselves, reduce noise:
      # remove the ones that occur inside the question wording by recomputing answers from "tail region" too.
      # Heuristic: take answers from the region AFTER the last question (often where the stacked answers live).
      last_q_pos = block.rindex(/\n\s*26\.\s/i) || block.rindex(/\n\s*\d{1,2}\.\s/i) || 0
      tail = block[last_q_pos..].to_s
      tail_answers = tail.scan(/\b(Yes|No)\b/i).flatten.map { |x| x.to_s.downcase }
      answers = tail_answers if tail_answers.size >= questions.size

      # --- 3) Build rows pairing question[i] with answers[i]
      rows = []
      questions.sort_by { |h| h[:number] }.each_with_index do |q, idx|
        ans = answers[idx] # may be nil if PDF extraction is broken
        answer_bool =
          if ans == "yes" then true
          elsif ans == "no" then false
          else nil
          end

        rows << {
          number: q[:number],
          question: q[:question],
          answer: answer_bool,
          explanation: nil,
          date: nil
        }
      end

      rows
    end

    ###############################################################################
    # HOSPITAL AFFILIATIONS / PRIVILEGES
    ###############################################################################
    def create_or_update_provider_hospital_privileges(provider_attest, text)
      data = parse_hospital_affiliations_general(text)
      return [] if data.blank?

      # If provider answered "No" to everything, store a single "no privileges" record.
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

      # If later you get PDFs where hospital rows exist, you can extend this:
      # parse actual hospital blocks and create rows.
      []
    end

    def parse_hospital_affiliations_general(text)
      return {} if text.blank?

      start = text.index(/^\s*HOSPITAL AFFILIATIONS\s*$/i) || text.index(/HOSPITAL AFFILIATIONS/i)
      return {} unless start

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

      {
        admitting_privileges: a1,
        admitting_arrangement: a2,
        non_admitting_affiliations: a3,
        all_no: (a1 == false && a2 == false && a3 == false)
      }
    end

    ###############################################################################
    # MEDICARE (multiple numbers)
    ###############################################################################
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
      return { participating: nil, rows: [] } unless start

      stop =
        text.index(/^\s*Medicaid\s*$/i, start) ||
        text.index(/^\s*ECFMG\s*$/i, start) ||
        text.length

      block = text[start...stop].to_s
      block = block.gsub("\f", "").gsub("\r", "")
      lines = block.lines.map { |l| l.strip }.reject(&:blank?)

      # ---- participating (your text has "Yes" right after "Medicare")
      participating = nil
      if lines[1].to_s.match?(/\A(Yes|No)\z/i)
        participating = to_bool(lines[1])
      else
        yn = block[/Are you a participating Medicare\s*provider\?\s*(Yes|No)/im, 1]
        participating = to_bool(yn) if yn.present?
      end

      rows = []

      # ---- Format A (best case): "Medicare Number : X   State : YY"
      block.scan(/Medicare Number\s*:\s*([A-Za-z0-9\-]+)\s*(?:State\s*:\s*([A-Z]{2}))?/i) do |num, st|
        rows << { medicare_number: num.strip, state: st&.strip }
      end

      # ---- Format B (your current output):
      # number on its own line, then next line is "Medicare Number :"
      block.scan(/(?m)^\s*([A-Za-z0-9\-]{3,})\s*$\n^\s*Medicare Number\s*:\s*$/) do |num|
        n = num.is_a?(Array) ? num.first : num
        next if n.blank?

        # Try to find "State : XX" near where this number appears
        idx = block.index(n.to_s)
        st = nil
        if idx
          window = block[idx, 250] || ""
          st = window[/State\s*:\s*([A-Z]{2})/i, 1]
        end

        rows << { medicare_number: n.strip, state: st&.strip }
      end

      rows.uniq! { |r| [r[:medicare_number], r[:state]] }

      { participating: participating, rows: rows }
    end
    
    ###############################################################################
    # MEDICADES (multiple numbers)
    ###############################################################################
    
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
      return { participating: nil, rows: [] } unless start

      stop =
        text.index(/^\s*ECFMG\s*$/i, start) ||
        text.index(/^\s*USMLE\s*$/i, start) ||
        text.length

      block = text[start...stop].to_s
      block = block.gsub("\f", "").gsub("\r", "")
      lines = block.lines.map { |l| l.strip }.reject(&:blank?)

      # Often it is:
      # Medicaid
      # Yes
      # Are you a participating Medicaid provider?
      participating = nil
      if lines[1].to_s.match?(/\A(Yes|No)\z/i)
        participating = to_bool(lines[1])
      else
        yn = block[/Are you a participating Medicaid\s*provider\?\s*(Yes|No)/im, 1]
        participating = to_bool(yn) if yn.present?
      end

      rows = []

      # Format A (best case): "Medicaid Number : X   State : YY"
      block.scan(/Medicaid Number\s*:\s*([A-Za-z0-9\-]+)\s*(?:State\s*:\s*([A-Z]{2}))?/i) do |num, st|
        rows << { medicaid_number: num.strip, state: st&.strip }
      end

      # Format B: number line then next line is "Medicaid Number :"
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

      { participating: participating, rows: rows }
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
          # Pass pdf_text to the mapper for better extraction context
          mapper.attributes_for(ProviderPersonalInformation, full_pdf_text: pdf_text).symbolize_keys
        rescue => e # Catching the exception and logging it is also an improvement
          Rails.logger.error("Error in AiFieldMapper: #{e.message}")
          {}
        end

      base_attrs = ai_attrs.present? ? ai_attrs : auto_map_by_schema(ProviderPersonalInformation)
      attrs      = base_attrs.slice(*columns)
      attrs      = cast_attributes(attrs, boolean_columns, date_columns, datetime_columns)

      attrs[:caqh_provider_attest_id] ||= caqh_provider_attest_id
      attrs[:caqh_provider_id]        ||= caqh_provider_id

      if attrs[:other_name_flag].nil?
        t = pdf_text
        attrs[:other_name_flag] = true  if t =~ /Have you used other names\?\s*Yes/i
        attrs[:other_name_flag] = false if t =~ /Have you used other names\?\s*No/i
      end

      ppi = provider_attest.provider_personal_informations.first_or_initialize
      ppi.assign_attributes(attrs)
      ppi.save!
      ppi
    end

    ###########################################################################
    # LICENSE PARSING
    ###########################################################################
    def create_or_update_provider_licensures(provider_attest)
      text = pdf_text
      return [] if text.blank?

      blocks = parse_license_blocks_from_pdf(text)
      return [] if blocks.blank?

      blocks = blocks.uniq { |b| [b[:state_abbr], b[:license_number]] }

      upserted = []

      blocks.each do |blk|
        state_id = lookup_state_id(blk[:state_abbr])
        next if state_id.nil? # IMPORTANT

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
          license_issue_date: to_date(blk[:issue_date]),
          license_expiration_date: to_date(blk[:expiration_date]),
          currently_practice_under_this: to_bool(blk[:currently_practice])
        )

        rec.save!
        upserted << rec
      end

      upserted
    end


    def parse_header_state_summary(text)
      result = {}

      start = text.index("License State")
      return result unless start

      stop   = text.index("PROFESSIONAL IDENTIFICATION NUMBERS", start) || text.length
      header = text[start...stop]

      chunks = header.split(/(?=License State)/)

      chunks.each_with_index do |chunk, idx|
        state = chunk[/License State\s*:\s*([A-Z]{2})/, 1]
        next if state.blank?

        practice =
          chunk[/Do you currently practice in this state\?\s*(Yes|No)/i, 1]

        dates = chunk.scan(/\b\d{1,2}\/\d{1,2}\/\d{4}\b/)
        issue = dates.first
        exp   = dates.last

        result[state] = {
          state_abbr:         state,
          issue_date:         issue,
          expiration_date:    exp,
          currently_practice: practice,
          is_primary_license: idx == 0
        }
      end

      result
    end

    def enrich_local_window!(blocks, text)
      blocks.each do |blk|
        num = blk[:license_number].to_s
        next if num.blank?

        idx = text.index(num)
        next unless idx

        window = text[[idx - 250, 0].max, 500] || ""

        blk[:expiration_date]    ||= window[/Expiration\s*Date\s*:\s*(\d+\/\d+\/\d{4})/i, 1]
        blk[:currently_practice] ||= window[/Do you currently practice in this state\?\s*(Yes|No)/i, 1]
      end
    end

    def enrich_from_header!(blocks, header)
      blocks.each do |blk|
        st = blk[:state_abbr]
        next unless header.key?(st)

        blk[:issue_date]         ||= header[st][:issue_date]
        blk[:expiration_date]    ||= header[st][:expiration_date]
        blk[:currently_practice] ||= header[st][:currently_practice]
        blk[:is_primary_license] ||= header[st][:is_primary_license]
      end
    end

    def parse_license_blocks_from_pdf(text)
      return [] if text.blank?

      # take area from first "License State" until "DEA Registration" (or next section)
      start = text.index(/License State\s*:/i) || text.index(/Professional License/i)
      return [] unless start

      stop =
        text.index(/DEA\s*Registration/i, start) ||
        text.index(/PROFESSIONAL IDENTIFICATION NUMBERS/i, start) ||
        text.length

      block = text[start...stop].to_s
      block = block.gsub("\f", "").gsub("\r", "")

      # Grab each license by splitting at "License State : XX"
      chunks = block.split(/(?=License State\s*:\s*[A-Z]{2})/i)

      chunks.filter_map do |chunk|
        st = chunk[/License State\s*:\s*([A-Z]{2})/i, 1]
        num = chunk[/License Number\s*:\s*([A-Za-z0-9\-]+)/i, 1]

        next if st.blank? || num.blank?

        {
          state_abbr: st.strip,
          license_number: num.strip,
          license_type: chunk[/License Type\s*:\s*([A-Za-z0-9\-]+)/i, 1]&.strip,
          status: chunk[/License Status\s*:\s*([A-Za-z]+)/i, 1]&.strip,
          issue_date: chunk[/Issue Date\s*:\s*(\d{1,2}\/\d{1,2}\/\d{4})/i, 1]&.strip,
          expiration_date: chunk[/Expiration Date\s*:\s*(\d{1,2}\/\d{1,2}\/\d{4})/i, 1]&.strip,
          currently_practice: chunk[/Do you currently practice in this state\?\s*(Yes|No)/i, 1]&.strip
        }
      end
    end

    def parse_trailing_licenses(text)
      idx = text.index("Attestation Date")
      return [] unless idx

      lines   = text[idx..].lines.map(&:strip).reject(&:blank?)
      results = []

      i = 0
      while i < lines.size - 3
        num    = lines[i]
        status = lines[i + 1]
        st     = lines[i + 3]

        if status =~ /(Active|Inactive|Expired)/ && st =~ /^[A-Z]{2}$/
          results << {
            state_abbr:         st,
            license_number:     num,
            status:             status,
            issue_date:         lines[i + 2],
            expiration_date:    nil,
            currently_practice: nil,
            license_type:       "MD"
          }
          i += 4
        else
          i += 1
        end
      end

      results
    end

    ###########################################################################
    # EDUCATION PARSER (MED SCHOOL + UNDERGRAD)
    ###########################################################################
    def parse_education_section(text)
      edu_block = text[/EDUCATION(.+?)TRAINING INFORMATION/m]
      return {} if edu_block.blank?

      # Extract a subsection safely
      prof = edu_block[/Professional School Information(.+?)(Undergraduate Education|\z)/m, 1].to_s
      under = edu_block[/Undergraduate Education(.+?)(TRAINING INFORMATION|\z)/m, 1].to_s

      {
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

    # Handles:
    # "Label : value"
    # "Label :\nvalue"
    # "Label :\nvalue continues\nuntil NextLabel :"
    def field_after_label(block, label)
      return nil if block.blank?

      # Stop at next "Label :" either on same line OR next line
      pattern = /
        #{Regexp.escape(label)}\s*:\s*
        (.*?)
        (?=
          \s{2,}[A-Za-z][A-Za-z0-9\/\-\&\(\)\s]{1,60}\s*:\s   # same line label (needs 2+ spaces)
          |\n\s*[A-Za-z][A-Za-z0-9\/\-\&\(\)\s]{1,60}\s*:\s   # next line label
          |\z
        )
      /mix

      v = block[pattern, 1]
      v = v.to_s.gsub("\f", " ").gsub(/\s+/, " ").strip
      v.presence
    end


    def create_practice_information_educations(provider_attest, text)
      data = parse_education_section(text)
      rows = []

      data.each_value do |edu|
        next if edu[:institution].blank?

        rows << PracticeInformationEducation.create!(
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
          start_date:              to_date(edu[:start]),
          end_date:                to_date(edu[:grad] || edu[:end])
        )
      end

      rows
    end

    ###########################################################################
    # TRAINING (RESIDENCY)
    ###########################################################################
    # ---- NEW: parses mm/yyyy + mm/dd/yyyy into Date
    def to_date_flexible(str, end_of_period: false)
      s = str.to_s
      return nil if s.blank?

      # 🔥 NEW: pull the first date token out of dirty strings
      token = s[/\b\d{1,2}\/\d{1,2}\/\d{4}\b|\b\d{1,2}\/\d{4}\b/, 0]
      return nil if token.blank?

      token = token.strip

      # mm/dd/yyyy
      if token.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
        return Date.strptime(token, "%m/%d/%Y") rescue nil
      end

      # mm/yyyy
      if token.match?(/\A\d{1,2}\/\d{4}\z/)
        m, y = token.split("/").map(&:to_i)
        return end_of_period ? Date.new(y, m, 1).end_of_month : Date.new(y, m, 1)
      end

      nil
    end

    # Small helper: try multiple possible label spellings
    def value_after_any_label(block, *labels)
      labels.each do |lbl|
        v = field_after_label(block, lbl)
        return v if v.present?
      end
      nil
    end

    def parse_training_section(text)
      block = text[/TRAINING INFORMATION(.+?)SPECIALTY INFORMATION/m]
      return [] if block.blank?

      # Split into multiple entries if present (Type : Residency / Internship / etc)
      parts = block.split(/(?=\bType\s*:\s*(?:Residency|Internship|Fellowship|Other)\b)/i)
      parts = [block] if parts.size == 1

      parts.filter_map do |p|
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

    def create_provider_educations(provider_attest, text)
      parse_training_section(text).map do |t|
        # upsert-ish so you don’t duplicate on reruns
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

    ###############################################################################
    # INSURANCE INFORMATION (Malpractice) — MULTIPLE RECORDS
    ###############################################################################
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

          # store big covered-locations blob (if you don't have a column for it, keep comment)
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
      return [] unless start

      stop =
        text.index(/^\s*HOSPITAL AFFILIATIONS\s*$/i, start) ||
        text.index(/^\s*WORK HISTORY\s*$/i, start) ||
        text.index(/^\s*PRACTICE LOCATIONS\s*$/i, start) ||
        text.length

      section = text[start...stop].to_s
      section = section.gsub("\f", "").gsub("\r", "")

      # Split each record on "Policy Number :" (keep the delimiter)
      parts = section.split(/(?=^\s*Policy Number\s*:)/mi)

      # If the first chunk is the header "INSURANCE INFORMATION..." without policy, drop it
      parts = parts.select { |p| p.match?(/^\s*Policy Number\s*:/i) }

      parts.map { |blk| parse_one_insurance_block(blk) }.compact
    end

    def parse_one_insurance_block(block)
      b = sanitize_insurance_block(block)

      get = ->(label) { field_after_label(b, label) }

      policy_number = get.call("Policy Number")
      return nil if policy_number.blank?

      covered = extract_multiline_value(b, "Covered Practice Locations", stop_labels: [
        "Original Effective Date",
        "Current Effective Date",
        "Current Expiration Date",
        "Carrier/Self Insured Name",
        "Street 1",
        "City",
        "State",
        "Zip Code",
        "Phone Number",
        "Fax Number",
        "Amount of coverage aggregate",
        "Do you have unlimited coverage",
        "Type of coverage",
        "Amount of coverage per occurrence",
        "Individual Coverage",
        "Self-Insured?"
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

    # Removes repeated "Provider Name / CAQH ID / Attestation Date" junk that breaks parsing
    def sanitize_insurance_block(block)
      s = block.to_s.gsub("\f", " ").gsub("\r", "")

      # Drop lines that are page headers/footers inserted mid-block
      s = s.gsub(/Provider Name\s*:\s*.*?\n/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+\s*\n/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}\s*\n/i, "")

      # Also remove inline occurrences (sometimes they appear on same line as other text)
      s = s.gsub(/Provider Name\s*:\s*.*?(?=Provider CAQH ID|Attestation Date|Policy Number|$)/i, "")
      s = s.gsub(/Provider CAQH ID\s*:\s*\d+/i, "")
      s = s.gsub(/Attestation Date\s*:\s*\d{1,2}\/\d{1,2}\/\d{4}/i, "")

      s
    end

    # Extract a large wrapped block value that ends when one of stop_labels appears
    def extract_multiline_value(block, label, stop_labels:)
      return nil if block.blank?

      start_idx = block.index(/#{Regexp.escape(label)}\s*:\s*/i)
      return nil unless start_idx

      after = block[start_idx..].sub(/#{Regexp.escape(label)}\s*:\s*/i, "")

      stop_idx = nil
      stop_labels.each do |lbl|
        i = after.index(/#{Regexp.escape(lbl)}\s*:/i) # <-- not anchored to ^
        stop_idx = i if i && (stop_idx.nil? || i < stop_idx)
      end

      val = stop_idx ? after[0...stop_idx] : after
      val = val.to_s.gsub(/\s+/, " ").strip
      val.presence
    end

    ###############################################################################
    # SPECIALTY INFORMATION PARSER — FINAL CORRECT VERSION
    ###############################################################################
    def parse_specialty_section(text)

      section = text[/SPECIALTY INFORMATION(.+?)Secondary Specialty/m]
      return {} if section.nil?

      # Remove weird line breaks inside wrapped values
      normalized = section.gsub("\n", " ").squeeze(" ")

      clean = ->(v) { v&.gsub(/\s+/, " ")&.strip }

      {
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

   ###############################################################################
    # CREATE ProviderSpecialties (FINAL)
    ###############################################################################
    def create_provider_specialties(provider_attest, text)
      data = parse_specialty_section(text)
      return [] if data.empty?

      attrs = {
        provider_attest_id:      provider_attest.id,
        caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,

        specialty_specialty_name: data[:specialty_name],

        specialty_board_name: data[:board_name],

        board_certified_flag: data[:board_certified],
        board_certified:      to_bool(data[:board_certified]),

        certification_number: data[:certification_number],

        initial_certification_date: to_date(data[:initial_cert_date]),

        board_certification_expires_flag: to_bool(data[:expires_flag]),

        hmo_flag: to_bool(data[:hmo_flag]),
        ppo_flag: to_bool(data[:ppo_flag]),
        pos_flag: to_bool(data[:pos_flag])
      }

      [ProviderSpecialty.create!(attrs)]
    end


    ###########################################################################
    # PRACTICE INFORMATION (ONLY FIELDS CLEARLY CORRECT FROM RAW_FIELDS)
    ###########################################################################
    #
    # We NO LONGER parse practice locations from pdf_text.
    # We rely ONLY on raw_fields, where each key already represents the
    # text after ":" in the CAQH PDF.
    #
    # For now we save:
    #   - practice_name
    #   - address / address2
    #   - important phones/fax/email
    #   - basic practice flags and IDs (NPI, Tax ID, W-9, group)
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

          currently_practicing_flag: to_bool(loc[:currently_practicing]),
          practice_intention_explanation: loc[:please_explain],

          patient_appointment_phone_number: loc[:appointment_phone],
          fax_number:                       loc[:fax],
          back_office_phone_number:         loc[:back_office_phone],
          phone_number:                     loc[:phone], # optional if you want

          coverage24x7_flag: to_bool(loc[:phone_coverage_24x7]),
          answering_service_phone_number: loc[:answering_service_phone],

          start_date: to_date(loc[:providers_start_date]),

          # office hours (nested in same table in your schema)
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
      return [] unless start

      stop =
        text.index(/^\s*HOSPITAL AFFILIATIONS\s*$/i, start) ||
        text.index(/^\s*WORK HISTORY\s*$/i, start) ||
        text.index(/^\s*PROFESSIONAL LIABILITY\s*$/i, start) ||
        text.length

      section = text[start...stop].to_s
      section = section.gsub("\f", "").gsub("\r", "")

      # Split each location by "General Information :" header
      blocks = section.split(/(?=^\s*General Information\s*:\s*$)/mi)
      blocks = blocks.select { |b| b.match?(/Practice Name\s*:/i) || b.match?(/Street\s*1\s*:/i) }

      blocks.map { |blk| parse_one_practice_location_block(blk) }.compact
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
      }

      # Office hours: parse day lines like "Monday Start Time : 8:00 AM End Time : 5:00 PM"
      loc[:office_hours] = parse_office_hours(s)

      loc
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
        # works whether it's on one line or wrapped
        # captures "8:00 AM" and "5:00 PM"
        m = s.match(/#{day_regex}.*?Start Time\s*:\s*([0-9]{1,2}:[0-9]{2}\s*(AM|PM)).*?End Time\s*:\s*([0-9]{1,2}:[0-9]{2}\s*(AM|PM))/im)
        next unless m

        out[:"#{k}_from"] = "#{m[1]}"
        out[:"#{k}_to"]   = "#{m[3]}"
      end

      out
    end

    def parse_time(str)
      return nil if str.blank?
      Time.zone.parse(str) rescue nil
    end


    ###########################################################################
    # HELPERS
    ###########################################################################
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


    def extract_specialty_section(text)
      return "" if text.blank?

      # Start at "SPECIALTY INFORMATION"
      start = text.index(/SPECIALTY INFORMATION/i)
      return "" unless start

      # Stop at the NEXT major section
      stop =
        text.index(/HOSPITAL AFFILIATIONS/i, start) ||
        text.index(/PROFESSIONAL LIABILITY/i, start) ||
        text.index(/WORK HISTORY/i, start) ||
        text.length

      text[start...stop]
    end

  end
end

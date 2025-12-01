# app/services/caqh/provider_importer.rb
require "shellwords"

module Caqh
  class ProviderImporter
    attr_reader :file_path, :raw_fields

    def initialize(file_path)
      @file_path  = file_path
      @raw_fields = Caqh::PdfFieldExtractor.new(file_path).call
    end

    ###########################################################################
    # MAIN ENTRYPOINT
    ###########################################################################
    def call
      ActiveRecord::Base.transaction do
        provider_attest = find_or_create_provider_attest

        ppi       = create_or_update_provider_personal_information(provider_attest)
        licenses  = create_or_update_provider_licensures(provider_attest)
        text      = pdf_text

        educ      = create_practice_information_educations(provider_attest, text)
        train     = create_provider_educations(provider_attest, text)
        practices = create_practice_informations(provider_attest)
        specialties = create_provider_specialties(provider_attest, text)

        {
          provider_attest:                 provider_attest,
          provider_personal_information:   ppi,
          provider_licensures:             licenses,
          practice_information_educations: educ,
          provider_educations:             train,
          practice_informations:           practices,
          provider_specialties: specialties,
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
          mapper.attributes_for(ProviderPersonalInformation).symbolize_keys
        rescue
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

      table_blocks   = parse_license_blocks_from_pdf(text)
      trailing       = parse_trailing_licenses(text)
      blocks         = table_blocks + trailing

      header = parse_header_state_summary(text)

      enrich_local_window!(blocks, text)
      enrich_from_header!(blocks, header)

      blocks = blocks.uniq { |b| [b[:state_abbr], b[:license_number]] }

      upserted = []
      blocks.each do |blk|
        next if blk[:state_abbr].blank? || blk[:license_number].blank?

        state_id = lookup_state_id(blk[:state_abbr])

        rec = ProviderLicensure.where(
          provider_attest_id: provider_attest.id,
          license_number:     blk[:license_number],
          state_id:           state_id
        ).first_or_initialize

        rec.assign_attributes(
          provider_attest_id:      provider_attest.id,
          caqh_provider_attest_id: provider_attest.caqh_provider_attest_id,
          state_id:                state_id,
          license_type:            blk[:license_type] || "MD",
          license_number:          blk[:license_number],
          license_issue_date:      to_date(blk[:issue_date]),
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
      start = text.index("Professional License")
      return [] unless start

      stop    = text.index("Provider Name", start) || text.length
      section = text[start...stop]

      lines   = section.lines.map(&:strip).reject(&:blank?)
      results = []

      i = 0
      while i < lines.size - 7
        if lines[i] =~ /^[A-Z]{2}$/ && lines[i + 1] =~ /^License State/
          results << {
            state_abbr:         lines[i],
            license_number:     lines[i + 2],
            license_type:       "MD",
            status:             lines[i + 4],
            issue_date:         lines[i + 6],
            expiration_date:    nil,
            currently_practice: nil
          }
          i += 8
        else
          i += 1
        end
      end

      results
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
      edu = text[/EDUCATION(.+?)TRAINING INFORMATION/m]
      return {} if edu.nil?

      clean = ->(v) { v&.gsub(/\s+/, " ")&.strip }

      med_school = {
        institution: clean[edu[/Professional School\s*:\s*(.+?)\n/, 1]],
        street:      clean[edu[/Street 1\s*:\s*(.+?)\n/, 1]],
        city:        clean[edu[/City\s*:\s*(.+?)\n/, 1]],
        state:       clean[edu[/State\s*:\s*(.+?)\n/, 1]],
        postal:      clean[edu[/Zip Code\s*:\s*(.+?)\n/, 1]],
        country:     clean[edu[/Country\s*:\s*(.+?)\n/, 1]],
        phone:       clean[edu[/Phone Number\s*:\s*(.+?)\n/, 1]],
        degree:      clean[edu[/Degree\s*:\s*(.+?)\n/, 1]],
        major:       clean[edu[/Area of Training.*?:\s*(.+?)\n/, 1]],
        start:       clean[edu[/Professional School Start Date\s*:\s*(.+?)\n/, 1]],
        end:         clean[edu[/Professional School End Date\s*:\s*(.+?)\n/, 1]],
        grad:        clean[edu[/Graduation Date\s*:\s*(.+?)\n/, 1]]
      }

      undergrad = {
        institution: clean[edu[/Undergraduate Education.+?School\s*:\s*(.+?)\n/m, 1]],
        street:      clean[edu[/Undergraduate Education.+?Street 1\s*:\s*(.+?)\n/m, 1]],
        city:        clean[edu[/Undergraduate Education.+?City\s*:\s*(.+?)\n/m, 1]],
        state:       clean[edu[/Undergraduate Education.+?State\s*:\s*(.+?)\n/m, 1]],
        postal:      clean[edu[/Undergraduate Education.+?Zip Code\s*:\s*(.+?)\n/m, 1]],
        country:     clean[edu[/Undergraduate Education.+?Country\s*:\s*(.+?)\n/m, 1]],
        degree:      clean[edu[/Undergraduate Education.+?Degree\s*:\s*(.+?)\n/m, 1]],
        major:       clean[edu[/Undergraduate Education.+?Major\s*:\s*(.+?)\n/m, 1]],
        start:       clean[edu[/Undergraduate Education.+?Start Date\s*:\s*(.+?)\n/m, 1]],
        end:         clean[edu[/Undergraduate Education.+?End Date\s*:\s*(.+?)\n/m, 1]],
        grad:        clean[edu[/Undergraduate Education.+?Graduation Date\s*:\s*(.+?)\n/m, 1]]
      }

      { med_school: med_school, undergrad: undergrad }
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
    def parse_training_section(text)
      block = text[/TRAINING INFORMATION(.+?)SPECIALTY INFORMATION/m]
      return [] if block.nil?

      clean = ->(v) { v&.gsub(/\s+/, " ")&.strip }

      training = {
        institution: clean[block[/Institution\/Hospital Name\s*:\s*(.+?)\n/, 1]],
        street:      clean[block[/Street1\s*:\s*(.+?)\n/, 1]],
        city:        clean[block[/City\s*:\s*(.+?)\n/, 1]],
        state:       clean[block[/State\s*:\s*(.+?)\n/, 1]],
        country:     clean[block[/Country\s*:\s*(.+?)\n/, 1]],
        postal:      clean[block[/Zip Code\s*:\s*(.+?)\n/, 1]],
        department:  clean[block[/Department\s*:\s*(.+?)\n/, 1]],
        specialty:   clean[block[/Specialty\s*:\s*(.+?)\n/, 1]],
        director:    clean[block[/Name of Director\s*:\s*(.+?)\n/, 1]],
        start:       clean[block[/Start Date\s*:\s*(.+?)\n/, 1]],
        end:         clean[block[/End Date\s*:\s*(.+?)\n/, 1]],
        completion:  clean[block[/Completion Date\s*:\s*(.+?)\n/, 1]]
      }

      return [] if training[:institution].blank?

      [training]
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


    def create_provider_educations(provider_attest, text)
      parse_training_section(text).map do |t|
        ProviderEducation.create!(
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

          start_date:      to_date(t[:start]),
          end_date:        to_date(t[:end]),
          completion_date: to_date(t[:completion])
        )
      end
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
    def create_practice_informations(provider_attest)
      practice_name = raw_fields["practice-name"]
      return [] if practice_name.blank?

      attrs = {
        provider_attest_id:        provider_attest.id,
        caqh_provider_attest_id:   provider_attest.caqh_provider_attest_id,

        # Core identity
        practice_name:             practice_name,
        address:                   raw_fields["street-1"],
        address2:                  raw_fields["street-2"],

        # We intentionally do NOT guess city/state/zip here, to avoid
        # mixing with home/billing addresses. Those can be added later
        # once you are happy with mappings.
        city:                      nil,
        state:                     nil,
        zip:                       nil,
        county:                    nil,
        country:                   nil,

        # Contact
        phone_number:                      raw_fields["back-office-phone-number"],
        patient_appointment_phone_number:  raw_fields["appointment-phone-number"],
        fax_number:                        raw_fields["faxnumber"],
        email_address:                     raw_fields["e-mail-address"],

        # Practice flags
        currently_practicing_flag:         to_bool(raw_fields["do-youpractice-at-this-location"]),
        practice_intention_explanation:    raw_fields["please-explain"],

        # Organization / tax info
        practice_type:          raw_fields["type-of-practice"],
        npi:                    raw_fields["do-youhave-anorganization-type-2-yes-organization-type-2-npi"],
        federal_tax_id:         raw_fields["taxid"],
        w9_practice_name:       raw_fields["w-9"],
        group_name:             raw_fields["group-name"],

        # Start date at this location
        start_date:             to_date(raw_fields["practice-providers-s-start-date"])
      }

      [PracticeInformation.create!(attrs)]
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
        cmd = "pdftotext #{Shellwords.escape(file_path.to_s)} -"
        `#{cmd}`
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

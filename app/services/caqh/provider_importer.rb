# app/services/caqh/provider_importer.rb
require "shellwords"

module Caqh
  class ProviderImporter
    attr_reader :file_path, :raw_fields

    def initialize(file_path)
      @file_path  = file_path
      @raw_fields = Caqh::PdfFieldExtractor.new(file_path).call
    end

    # Main entrypoint
    #
    # Returns:
    # {
    #   provider_attest: ProviderAttest,
    #   provider_personal_information: ProviderPersonalInformation,
    #   provider_licensures: [ProviderLicensure, ...],
    #   raw_fields: { ... }
    # }
    def call
      ActiveRecord::Base.transaction do
        provider_attest = find_or_create_provider_attest
        Rails.logger.info "CAQH ProviderImporter: using ProviderAttest id=#{provider_attest.id} caqh=#{provider_attest.caqh_provider_attest_id}"

        ppi = create_or_update_provider_personal_information(provider_attest)
        Rails.logger.info "CAQH ProviderImporter: PPI id=#{ppi.id} first_name=#{ppi.first_name.inspect} last_name=#{ppi.last_name.inspect}"

        licenses = create_or_update_provider_licensures(provider_attest)
        Rails.logger.info "CAQH ProviderImporter: created #{licenses.size} provider_licensures for ProviderAttest id=#{provider_attest.id}"

        {
          provider_attest: provider_attest,
          provider_personal_information: ppi,
          provider_licensures: licenses,
          raw_fields: raw_fields
        }
      end
    end

    private

    # ------------------------------------------------------------------------
    # CAQH ID helpers
    # ------------------------------------------------------------------------

    def caqh_provider_attest_id
      val = raw_fields["alan-provider-caqh-id"] ||
            raw_fields["provider-attest-id"]    ||
            raw_fields["caqh-provider-attest-id"] ||
            raw_fields["attestation-id"]

      return val.to_i if val.present? && val.to_s =~ /^\d+$/

      # Fallback: scan values for an 8–10 digit number
      raw_fields.values.each do |v|
        next if v.blank?
        if v.to_s =~ /(\d{8,10})/
          return $1.to_i
        end
      end

      nil
    end

    def caqh_provider_id
      raw_fields["caqh-provider-id"] ||
        raw_fields["provider-id"]
    end

    def find_or_create_provider_attest
      id_val = caqh_provider_attest_id || caqh_provider_id
      raise "CAQH Provider Attest ID not found in PDF" if id_val.blank?

      ProviderAttest.find_or_create_by!(
        caqh_provider_attest_id: id_val.to_i
      )
    end

    # ------------------------------------------------------------------------
    # ProviderPersonalInformation – AI + fallback + extra boolean parsing
    # ------------------------------------------------------------------------

    def create_or_update_provider_personal_information(provider_attest)
      boolean_columns  = boolean_columns_for(ProviderPersonalInformation)
      date_columns     = date_columns_for(ProviderPersonalInformation)
      datetime_columns = datetime_columns_for(ProviderPersonalInformation)
      columns          = ProviderPersonalInformation.columns_hash.keys.map(&:to_sym)

      # 1) Try AI mapper (may rate-limit → we rescue)
      ai_attrs =
        begin
          mapper = Caqh::AiFieldMapper.new(raw_fields)
          mapper.attributes_for(ProviderPersonalInformation).symbolize_keys
        rescue => e
          Rails.logger.warn "CAQH ProviderImporter: AiFieldMapper failed (#{e.class}: #{e.message}), falling back to auto_map_by_schema"
          {}
        end

      # 2) Fallback: schema-based auto mapping from raw_fields
      base_attrs =
        if ai_attrs.present?
          Rails.logger.info "CAQH ProviderImporter: using AI-mapped attributes for PPI"
          ai_attrs
        else
          Rails.logger.info "CAQH ProviderImporter: using auto_map_by_schema for PPI"
          auto_map_by_schema(ProviderPersonalInformation)
        end

      # 3) Keep only real columns
      attrs = base_attrs.slice(*columns)

      # 4) Type casting
      attrs = cast_attributes(attrs, boolean_columns, date_columns, datetime_columns)

      # 5) Inject CAQH IDs
      attrs[:caqh_provider_attest_id] ||= caqh_provider_attest_id&.to_i if caqh_provider_attest_id.present?
      attrs[:caqh_provider_id]        ||= caqh_provider_id&.to_i        if caqh_provider_id.present?

      # 6) Derive other_name_flag from PDF text if not already set
      if attrs[:other_name_flag].nil?
        derived_flag = derive_other_name_flag_from_pdf
        attrs[:other_name_flag] = derived_flag unless derived_flag.nil?
        Rails.logger.info "CAQH ProviderImporter: derived other_name_flag=#{derived_flag.inspect} from PDF text"
      end

      Rails.logger.info "CAQH ProviderImporter: final PPI attrs (subset) = #{attrs.slice(:first_name, :middle_name, :last_name, :ssn, :npi, :primary_practice_state, :other_name_flag).inspect}"

      ppi = provider_attest.provider_personal_informations.first_or_initialize
      ppi.assign_attributes(attrs)
      ppi.save!
      ppi
    end

    def derive_other_name_flag_from_pdf
      t = pdf_text
      return nil if t.blank?

      if t =~ /Have you used other names\?\s*Yes/i
        true
      elsif t =~ /Have you used other names\?\s*No/i
        false
      else
        nil
      end
    end

    # ------------------------------------------------------------------------
    # ProviderLicensures – build from raw_fields
    # ------------------------------------------------------------------------
    #
    # For now we map ONE licensure, using keys:
    #   "license-state", "license-number", "license-type",
    #   "license-status", "issue-date", "expirationdate"
    #
    # Example value you showed:
    #   License State : NY Do you currently practice in this state? Yes
    #   License Number : 217923 License Type : MD
    #   License Status : Active
    #   Issue Date : 06/22/2000 Expiration Date : 12/31/2025
    #
    # Those are exactly the values in raw_fields.

    def create_or_update_provider_licensures(provider_attest)
		  text = pdf_text
		  if text.blank?
		    Rails.logger.warn "pdf_text was blank — skipping licenses"
		    return []
		  end

		  blocks = parse_all_license_blocks(text)
		  Rails.logger.info "Parsed #{blocks.size} licenses from pdf_text"

		  provider_attest.provider_licensures.destroy_all

		  blocks.map.with_index do |blk, idx|
		    Rails.logger.info "Creating license ##{idx+1}: #{blk.inspect}"

		    state_id = lookup_state_id(blk[:state])

		    ProviderLicensure.create!(
		      provider_attest_id:        provider_attest.id,
		      caqh_provider_attest_id:   provider_attest.caqh_provider_attest_id,
		      state_id:                  state_id,
		      license_number:            blk[:license_number],
		      license_type:              blk[:license_type],
		      license_issue_date:        to_date(blk[:issue_date]),
		      license_expiration_date:   to_date(blk[:expiration_date]),
		      currently_practice_under_this: blk[:currently_practice]
		    )
		  end
		end

    # Pull license info out of flat fields
    def build_licenses_from_raw_fields
      state_raw   = raw_fields["license-state"]
      number_raw  = raw_fields["license-number"]
      type_raw    = raw_fields["license-type"]
      status_raw  = raw_fields["license-status"]
      issue_raw   = raw_fields["issue-date"]
      exp_raw     = raw_fields["expirationdate"]

      Rails.logger.info "CAQH ProviderImporter: raw license fields = #{{
        "license-state"   => state_raw,
        "license-number"  => number_raw,
        "license-type"    => type_raw,
        "license-status"  => status_raw,
        "issue-date"      => issue_raw,
        "expirationdate"  => exp_raw
      }.inspect}"

      # nothing to do if we don't even have a number / state
      return [] if state_raw.blank? && number_raw.blank?

      state_abbr = nil
      currently_practice = nil

      if state_raw.present?
        # e.g. "NY                                   Do youcurrentlypractice inthis state?Yes"
        if state_raw =~ /\b([A-Z]{2})\b/
          state_abbr = $1
        end

        if state_raw =~ /Yes/i
          currently_practice = true
        elsif state_raw =~ /No/i
          currently_practice = false
        end
      end

      [{
        state_abbr:          state_abbr,
        license_number:      number_raw&.strip,
        license_type:        type_raw&.strip,
        status:              status_raw&.strip,
        issue_date:          issue_raw&.strip,
        expiration_date:     exp_raw&.strip,
        currently_practice:  currently_practice
      }]
    end

    # Robust state lookup so we don’t assume a specific column name
    def lookup_state_id(state_abbr)
      return nil if state_abbr.blank?

      col =
        if State.column_names.include?("abbreviation")
          :abbreviation
        elsif State.column_names.include?("code")
          :code
        elsif State.column_names.include?("state_code")
          :state_code
        elsif State.column_names.include?("state_abbreviation")
          :state_abbreviation
        elsif State.column_names.include?("state")
          :state
        elsif State.column_names.include?("name")
          :name
        else
          nil
        end

      unless col
        Rails.logger.warn "CAQH ProviderImporter: no suitable column on states table to map #{state_abbr.inspect}"
        return nil
      end

      State.find_by(col => state_abbr)&.id
    end

    # ------------------------------------------------------------------------
    # Generic helpers
    # ------------------------------------------------------------------------

    def pdf_text
      @pdf_text ||= begin
        cmd = "pdftotext #{Shellwords.escape(file_path.to_s)} -"
        Rails.logger.info "CAQH ProviderImporter: running #{cmd}"
        `#{cmd}`
      rescue => e
        Rails.logger.error "CAQH ProviderImporter: pdftotext failed: #{e.class}: #{e.message}"
        ""
      end
    end

    def cast_attributes(attrs, boolean_columns, date_columns, datetime_columns)
      attrs.each_with_object({}) do |(attr_name, value), h|
        if boolean_columns.include?(attr_name)
          h[attr_name] = to_bool(value)
        elsif date_columns.include?(attr_name)
          h[attr_name] = to_date(value)
        elsif datetime_columns.include?(attr_name)
          h[attr_name] = to_datetime(value)
        else
          h[attr_name] = value
        end
      end
    end

    def boolean_columns_for(klass)
      klass.columns_hash.select { |_name, col| col.type == :boolean }.keys.map(&:to_sym)
    end

    def date_columns_for(klass)
      klass.columns_hash.select { |_name, col| col.type == :date }.keys.map(&:to_sym)
    end

    def datetime_columns_for(klass)
      klass.columns_hash.select { |_name, col| col.type == :datetime }.keys.map(&:to_sym)
    end

    def to_bool(value)
      return nil if value.nil?
      v = value.to_s.strip.downcase
      return true  if %w[yes y true t 1].include?(v)
      return false if %w[no n false f 0].include?(v)
      nil
    end

    def to_date(value)
      return nil if value.blank?
      Date.parse(value.to_s) rescue nil
    end

    def to_datetime(value)
      return nil if value.blank?
      Time.zone.parse(value.to_s) rescue nil
    end

    # schema-based mapping: normalize raw_keys and match against column names
    def auto_map_by_schema(model_class)
      columns = model_class.columns_hash.keys.map(&:to_s)

      normalized = {}

      raw_fields.each do |raw_key, value|
        next if value.blank?

        # "First-Name" => "first_name"; "birthdate" => "birthdate"
        norm = raw_key.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
        normalized[norm] ||= value
      end

      attrs = {}
      normalized.each do |norm_key, value|
        if columns.include?(norm_key)
          attrs[norm_key.to_sym] = value
        end
      end

      attrs
    end

    def parse_all_license_blocks(text)
		  blocks = []

		  # This regex matches repeating license sections like:
		  # License State : NY Do you currently practice in this state? Yes
		  # License Number : 217923 License Type : MD
		  # License Status : Active
		  # Issue Date : 06/22/2000 Expiration Date : 12/31/2025
		  regex = /
		    License\ State\s*:\s*(?<state>[A-Z]{2})[^\n]*?
		    currently\spractice.*?(?<practice>Yes|No)?[^\n]*?
		    License\ Number\s*:\s*(?<number>\S+)[^\n]*?
		    License\ Type\s*:\s*(?<ltype>\S+)[^\n]*?
		    License\ Status\s*:\s*(?<status>[A-Za-z]+)[^\n]*?
		    Issue\ Date\s*:\s*(?<issue>\d{2}\/\d{2}\/\d{4})[^\n]*?
		    Expiration\ Date\s*:\s*(?<exp>\d{2}\/\d{2}\/\d{4})
		  /ixm

		  text.scan(regex) do |match|
		    m = Regexp.last_match
		    blocks << {
		      state:               m[:state],
		      currently_practice:  to_bool(m[:practice]),
		      license_number:      m[:number],
		      license_type:        m[:ltype],
		      status:              m[:status],
		      issue_date:          m[:issue],
		      expiration_date:     m[:exp]
		    }
		  end

		  Rails.logger.info "CAQH ProviderImporter: FOUND #{blocks.size} LICENSE BLOCKS"
		  blocks
		end
  end
end

# app/services/caqh/provider_importer.rb
module Caqh
  class ProviderImporter
    attr_reader :file_path, :raw_fields

    def initialize(file_path)
      @file_path  = file_path
      @raw_fields = Caqh::PdfFieldExtractor.new(file_path).call
    end

    # Main entrypoint
    def call
      ActiveRecord::Base.transaction do
        provider_attest = find_or_create_provider_attest
        ppi             = create_or_update_provider_personal_information(provider_attest)

        # later: call methods to create licenses, deas, cds, educations, employments, practice infos, etc.
        # create_medical_licenses(provider_attest)
        # create_deas(provider_attest)
        # create_cds(provider_attest)
        # ...

        ppi
      end
    end

    private

    # ----- helpers for ProviderAttest / IDs -----

    # Try to find CAQH provider attest id and caqh provider id from flat fields
    # You may need to adjust keys to match your actual PDF labels.
   def caqh_provider_attest_id
		  # 1. Directly from extracted normalized key
		  val = raw_fields["provider-attest-id"] ||
		        raw_fields["caqh-provider-attest-id"] ||
		        raw_fields["attestation-id"]

		  return val.to_i if val.present? && val.to_s =~ /^\d+$/

		  # 2. Fallback: scan ALL field values for an 8–10 digit CAQH ID
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
      # NOTE: caqh_provider_attest_id is an integer column
      id_val = caqh_provider_attest_id
      raise "CAQH Provider Attest ID not found in PDF" if id_val.blank?

      ProviderAttest.find_or_create_by!(
        caqh_provider_attest_id: id_val.to_i
      )
    end

    # ----- ProviderPersonalInformation mapping -----

    def create_or_update_provider_personal_information(provider_attest)
		  field_map        = ProviderPersonalInformation::FLAT_FIELD_MAP
		  boolean_columns  = boolean_columns_for(ProviderPersonalInformation)
		  date_columns     = date_columns_for(ProviderPersonalInformation)
		  datetime_columns = datetime_columns_for(ProviderPersonalInformation)
		  columns          = ProviderPersonalInformation.columns_hash.keys.map(&:to_sym)

		  attrs = {}

		  field_map.each do |field_key, attr_name|
		    # skip entries that don't exist in schema
		    next unless columns.include?(attr_name)

		    value = lookup_value_for_field_key(field_key)
		    next if value.blank?

		    if boolean_columns.include?(attr_name)
		      attrs[attr_name] = to_bool(value)
		    elsif date_columns.include?(attr_name)
		      attrs[attr_name] = to_date(value)
		    elsif datetime_columns.include?(attr_name)
		      attrs[attr_name] = to_datetime(value)
		    else
		      attrs[attr_name] = value
		    end
		  end

		  attrs[:caqh_provider_attest_id] ||= caqh_provider_attest_id&.to_i if caqh_provider_attest_id.present?
		  attrs[:caqh_provider_id]        ||= caqh_provider_id&.to_i        if caqh_provider_id.present?

		  ppi = provider_attest.provider_personal_informations.first_or_initialize
		  ppi.assign_attributes(attrs)
		  ppi.save!
		  ppi
		end


    # Given a FIELD_MAP key like "first_name" or "ps-dob",
    # try to find the corresponding value in raw_fields.
    def lookup_value_for_field_key(field_key)
      variants = []
      variants << field_key.to_s
      variants << field_key.to_s.tr("_", "-")
      variants << field_key.to_s.tr("-", "_")

      # normalized variants like "ps-dob", "ps_dob"
      variants.uniq!

      variants.each do |candidate|
        v = raw_fields[candidate]
        return v if v.present?
      end

      nil
    end

    # ----- generic type casting helpers -----

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
  end
end

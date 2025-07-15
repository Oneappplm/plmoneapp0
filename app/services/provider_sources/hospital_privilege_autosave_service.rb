module ProviderSources
  class HospitalPrivilegeAutosaveService
    FIELD_MAP = {
      "state_abbr" => "state",
      "hp_facility_name" => "hospital_name",
      "hp_no_longer_in_business" => "no_longer_in_business_flag",
      "hp_mso_address_line1" => "address",
      "hp_mso_address_line2" => "address2",
      "hp_city" => "city",
      "hp_zipcode" => "zip_code",
      "hp_mso_telephone_number" => "phone_number",
      "hp_ext" => "extension",
      "hp_mso_fax_number" => "fax_number",
      "hp_mso_email_address" => "email_address",
      "hp_department_name" => "department_name",
      "hp_division_name" => "division_name",
      "director_first_name" => "contact_first_name",
      "director_last_name" => "contact_last_name",
      "unrestricted_privileges" => "unrestricted_privileges_flag",
      "privileges_temporary" => "temporary_privileges_flag",
      "privilege_status" => "staff_category"
    }.freeze

    def initialize(source:, field_name:, value:, privilege_id:)
      @source = source
      @field_name = field_name
      @value = value
      @privilege_id = privilege_id
    end

    def perform
      index, attribute = extract_index_and_attribute(@field_name)
      return { error: "Invalid field name" } unless attribute

      source_privilege = find_or_initialize_source_privilege
      source_privilege.assign_attributes(attribute => @value)

      if source_privilege.save(validate: false)
        sync_to_provider_privilege(source_privilege, attribute, @value)
        { status: "saved", id: source_privilege.id }
      else
        { error: source_privilege.errors.full_messages }
      end
    end

    private

    def extract_index_and_attribute(field_name)
      if field_name =~ /\Ahospital_privileges\[(\d+)\]\[(\w+)\]\z/
        [Regexp.last_match(1).to_i, Regexp.last_match(2)]
      else
        [nil, nil]
      end
    end

    def find_or_initialize_source_privilege
      if @privilege_id.present?
        @source.hospital_privileges.find_or_initialize_by(id: @privilege_id)
      else
        @source.hospital_privileges.build
      end
    end

    def sync_to_provider_privilege(source_privilege, attribute, value)
      attest = @source.provider_personal_information.provider_attest
      return unless attest

      provider_privilege = attest.provider_hospital_privileges.find_or_initialize_by(
        caqh_provider_hospital_id: source_privilege.id
      )

      db_field = FIELD_MAP[attribute]
      return unless db_field.present? && provider_privilege.respond_to?("#{db_field}=")

      provider_privilege.send("#{db_field}=", value)
      provider_privilege.save(validate: false)
    end
  end
end

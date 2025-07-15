module ProviderSources
  class ProviderEducationAutosaveService
    UNDERGRAD_MAP = {
      "undergraduate_school_name" => "institution_name",
      "address_line1" => "address",
      "address_line2" => "address2",
      "city" => "city",
      "school_location" => "state",
      "zipcode" => "postal_code",
      "telephone_number" => "phone_number",
      "fax_number" => "fax_number",
      "email" => "email_address",
      "date_start" => "start_date",
      "date_graduation" => "end_date",
      "degree_awarded" => "degree_degree_abbreviation",
      "incomplete" => "program_completed_flag",
      "reason" => "incomplete_explanation"
    }.freeze

    GRADUATE_MAP = {
      "professional_school_name" => "institution_name",
      "address_line1" => "address",
      "address_line2" => "address2",
      "city" => "city",
      "location" => "state",
      "zip_code" => "postal_code",
      "telephone_number" => "phone_number",
      "fax_number" => "fax_number",
      "email" => "email_address",
      "specialization" => nil,  # Column does not exist in the table
      "degree_awarded" => "degree_degree_abbreviation",
      "start_date" => "start_date",
      "graduation_date" => "end_date",
      "education_completed" => "program_completed_flag",
      "incomplete_education_reason" => "incomplete_explanation",
      "graduate_type" => nil,  # Column `program_type` does not exist in this table
      "faculty_director_first_name" => nil,  # No associate fields in this table
      "faculty_director_last_name" => nil,
      "director_degree" => nil
    }.freeze

    def initialize(source:, field_name:, value:, education_id:)
      @source = source
      @field_name = field_name
      @value = value
      @education_id = education_id
      @type = detect_type_from_field_name
    end

    def perform
      index, attribute = extract_index_and_attribute(@field_name)
      return { error: "Invalid field name" } unless attribute

      case @type
      when "graduate"
        save_graduate_detail(attribute)
      when "undergrad"
        save_undergrad_school(attribute)
      else
        { error: "Unknown education type" }
      end
    end

    private

    def detect_type_from_field_name
      if @field_name.include?("provider_source_undergrad_schools")
        @education_type_name = "Undergraduate"
        "undergrad"
      elsif @field_name.include?("graduate_details")
        @education_type_name = "Graduate"
        "graduate"
      else
        raise ArgumentError, "Unknown education field type in field name: #{@field_name}"
      end
    end

    def extract_index_and_attribute(field_name)
      pattern = @type == "undergrad" ? /provider_source_undergrad_schools\[(\d+)\]\[(\w+)\]/ :
                                       /graduate_details\[(\d+)\]\[(\w+)\]/
      if field_name =~ pattern
        [Regexp.last_match(1).to_i, Regexp.last_match(2)]
      else
        [nil, nil]
      end
    end

    def save_graduate_detail(attribute)
      record = find_or_initialize_graduate_detail
      record.assign_attributes(attribute => @value)

      if record.save(validate: false)
        sync_to_provider_education(record, attribute, @value)
        { status: "saved", id: record.id }
      else
        { error: record.errors.full_messages }
      end
    end

    def save_undergrad_school(attribute)
      record = find_or_initialize_undergrad_school
      record.assign_attributes(attribute => @value)

      if record.save(validate: false)
        sync_to_provider_education(record, attribute, @value)
        { status: "saved", id: record.id }
      else
        { error: record.errors.full_messages }
      end
    end

    def find_or_initialize_graduate_detail
      if @education_id.present?
        GraduateDetail.find_by(id: @education_id, provider_source_id: @source.id) || @source.graduate_details.build
      else
        @source.graduate_details.build
      end
    end

    def find_or_initialize_undergrad_school
      if @education_id.present?
        @source.provider_source_undergrad_schools.find_by(id: @education_id) || @source.provider_source_undergrad_schools.build
      else
        @source.provider_source_undergrad_schools.build
      end
    end

    def sync_to_provider_education(source_education, attribute, value)
      attest = @source.provider_personal_information&.provider_attest
      return unless attest

      edu = if @education_id.present?
              attest.practice_information_educations.find_by(caqh_practice_information_education_id: source_education.id) ||
                attest.practice_information_educations.build(caqh_practice_information_education_id: source_education.id)
            else
              attest.practice_information_educations.build(caqh_practice_information_education_id: source_education.id)
            end

      db_field = field_map[attribute]
      return unless db_field.present? && edu.respond_to?("#{db_field}=")

      edu.send("#{db_field}=", normalize_value(attribute, value))
      edu.education_type_name = @education_type_name if edu.respond_to?(:education_type_name=)
      edu.save(validate: false)

      if @type == "graduate" && ["faculty_director_first_name", "faculty_director_last_name"].include?(attribute)
        associate = edu.provider_education_associates.find_or_initialize_by(
          associate_type_associate_type_description: "Faculty Director",
          provider_attest_id: attest.id
        )
        assoc_field = GRADUATE_MAP[attribute]
        associate.send("#{assoc_field}=", value)
        associate.save(validate: false)
      end
    end

    def field_map
      @type == "undergrad" ? UNDERGRAD_MAP : GRADUATE_MAP
    end

    def normalize_value(attribute, value)
      if %w[incomplete education_completed].include?(attribute)
        value == "false" ? true : false
      else
        value
      end
    end
  end
end

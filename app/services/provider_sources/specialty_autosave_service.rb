# app/services/provider_sources/specialty_autosave_service.rb
module ProviderSources
  class SpecialtyAutosaveService
    FIELD_MAP = {
      "speciality" => "specialty_specialty_name",
      "speciality_ranking" => "specialty_percent",
      "board_certified" => "board_certified_flag",
      "certifying_board" => "specialty_board_name",
      "address_line_1" => "specialty_board_address",
      "address_line_2" => "specialty_board_address2",
      "city" => "specialty_board_city",
      "zipcode" => "specialty_board_postal_code",
      "state" => "specialty_board_state",
      "bord_certificate_number" => "certification_number",
      "initial_certification_date" => "initial_certification_date",
      "expiration_certification_date" => "expiration_date",
      "recertification_date" => "recertification_date",
      "admissibility_expiration_date" => "admissibility_expiration_date",
      "board_exam_results_pending" => "results_pending_flag",
      "pending_certifying_board" => "results_pending_specialty_board_name",
      "board_exam_date" => "future_board_exam_date",
      "accepted_for_certification_exam" => "planning_to_take_board_exam_flag",
      "intend_date_apply" => "intend_apply_certification_date",
      "intend_applied_for_certification_exam" => "intend_apply_certification_flag",
      "specialties_no_board_exam_reason" => "no_certification_explanation"
    }.freeze

    def initialize(source:, field_name:, value:, specialty_id:)
      @source = source
      @field_name = field_name
      @value = value
      @specialty_id = specialty_id
    end

    def perform
      index, attribute = extract_index_and_attribute(@field_name)
      return { error: "Invalid field name" } unless attribute

      specialty = find_or_initialize_source_specialty
      specialty.assign_attributes(attribute => @value)

      if specialty.save(validate: false)
        sync_to_provider_specialty(specialty, attribute, @value)
        { status: "saved", id: specialty.id }
      else
        { error: specialty.errors.full_messages }
      end
    end

    private

    def extract_index_and_attribute(field_name)
      if field_name =~ /\Aprovider_source_specialities\[(\d+)\]\[(\w+)\]\z/
        [Regexp.last_match(1).to_i, Regexp.last_match(2)]
      else
        [nil, nil]
      end
    end

    def find_or_initialize_source_specialty
      if @specialty_id.present?
        @source.provider_source_specialities.find_or_initialize_by(id: @specialty_id)
      else
        @source.provider_source_specialities.build
      end
    end

    def sync_to_provider_specialty(source_specialty, attribute, value)
      attest = @source.provider_personal_information.provider_attest
      return unless attest

      provider_specialty = if @specialty_id.present?
        attest.provider_specialties.find_by(caqh_provider_specialty_id: source_specialty.id) ||
          attest.provider_specialties.build(caqh_provider_specialty_id: source_specialty.id)
      else
        attest.provider_specialties.build(caqh_provider_specialty_id: source_specialty.id)
      end

      db_field = FIELD_MAP[attribute]
      return unless db_field.present? && provider_specialty.respond_to?("#{db_field}=")

      provider_specialty.send("#{db_field}=", value)
      provider_specialty.save(validate: false)
    end
  end
end

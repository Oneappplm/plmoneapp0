module ProviderSources
  class AutosaveService
    DEA_FIELD_MAP = {
      "registration_number" => :dea_number,
      "state" => :state,
      "issue_date" => :application_date,
      "expiration_date" => :expiration_date,
      "schedule_limit_explanation" => :dea_license_limitation_explanation,
      "full_schedule" => :full_schedule,
      "schedules_held" => :schedules_held,
      "dea_license_limitation_flag" => :dea_license_limitation_flag,
      "no_dea_explanation" => :no_dea_explanation,
      "dea_not_expire" => :dea_license_limitation_flag
    }.freeze

    CDS_FIELD_MAP = {
      "registration_number" => :cds_number,
      "state" => :state,
      "issue_date" => :issue_date,
      "expiration_date" => :expiration_date,
      "practicing_in_state" => :currently_practicing_flag,
      "full_schedule_9" => :cds_status,
      "schedule_limit_explanation" => :cds_limitation_explanation
    }.freeze

    LICENSURE_FIELD_MAP = {
      "licensure_state" => :state_id,
      "license_type" => :license_type,
      "license_number" => :license_number,
      "licensure_issue_date" => :license_issue_date,
      "licensure_expiration_date" => :license_expiration_date,
      "licensure_practice_state" => :currently_practice_under_this,
      "licensure_primary_license" => :is_primary_license,
      "licensure_require_supervision" => :level_require_supervision
    }.freeze

    MEDICARE_FIELD_MAP = {
      "participating_medicare_number" => :medicare_number,
      "participating_medicare_state" => :state,
      "other_id_voluntarily_medicare" => :medicare_opt_out
    }.freeze

    MEDICAID_FIELD_MAP = {
      "participating_medicaid_number" => :medicaid_number,
      "participating_medicaid_state" => :state
    }.freeze

    OTHER_CERTIFICATION_FIELD_MAP = {
      "other_cert_field" => :certification_flag,
      "other_certification_type" => :certification_type,
      "other_certification_number" => :certification_number,
      "other_certification_state" => :state,
      "other-certification-issue-date" => :obtained_date,
      "other_certification_expiration_date" => :expiration_date,
      "other_certification_not_expire" => :certification_status
    }.freeze

    TRAINING_FIELD_MAP = {
      "tf-location" => :state,
      "tf-psn" => :institution_name,
      "tf-address-line1" => :address,
      "tf-address-line2" => :address2,
      "tf-city" => :city,
      "tf-zipcode" => :postal_code,
      "tf-telephone-number" => :phone_number,
      "tf-fax-number" => :fax_number,
      "tf-email" => :email_address,
      "tr_training_types" => :program_type,
      "tr_specialties" => :specialty_specialty_name,
      "tf-pd-first-name" => :program_director, # Optionally merge full name
      "tf-pd-last-name" => :program_director,  # Same field
      "tf-pf-degree" => :program_director_degree,
      "tf-pd-email-address" => :contact,
      "tf-start-date" => :start_date,
      "tf-end-date" => :end_date,
      "incomplete_training" => :program_completed_flag,
      "training_reason" => :incomplete_explanation,
      "tfu-affiliated-program" => :affiliated_university_name,
      "tfu_affiliated_location" => :province,
      "tfu-address-line1" => :address,
      "tfu-address-line2" => :address2,
      "tfu-city" => :city,
      "tfu-zipcode" => :postal_code,
      "tfu-telephone-number" => :phone_number,
      "tfu-fax-number" => :fax_number
    }.freeze

    LIABILITY_FIELD_MAP = {
      "lf-carrier-location" => :state,
      "lf-carrier-name" => :insurance_carrier_name,
      "lf-address-line1" => :address,
      "lf-address-line2" => :address2,
      "lf-city" => :city,
      "lf-zipcode" => :postal_code,
      "lf-telephone-number" => :phone_number,
      "lf-ext" => :phone_extension,
      "lf-fax-number" => :fax_number,
      "lf-email-address" => :email_address,
      "lf-policy-type" => :type_of_policy,
      "lf-coverage-type" => :insurance_coverage_type_insurance_coverage_type_description,
      "lf-policy-holder-name" => :policy_holder,
      "lf-policy-number" => :policy_number,
      "has_tail_coverage" => :tail_coverage,
      "has_carrier_excluded" => :current_carrier_excluded,
      "lf-not-insured-coverage-amount" => :coverage_amount_occurrence,
      "lf-not-insured-unlimited-coverage-amount" => :unlimited_coverage_flag,
      "lf-not-insured-email-aggregate-coverage" => :coverage_amount_aggregate,
      "lf-not-insured-unlimited-aggregate-coverage" => :unlimited_coverage_flag, # same field used twice
      "lf-not-insured-original-effective-date" => :original_start_date,
      "lf-not-insured-effective-date" => :effective_date,
      "lf-not-insured-original-expiration-date" => :end_date,
      "lf-not-insured-not-expiry" => :liability_not_applicable
    }.freeze

    MALPRACTICE_FIELD_MAP = {
      "mc-occurence-date" => :occurrence_date,
      "mc-date-claim-filed" => :claim_date,
      "mc-claim-status" => :provider_status,
      "mc-amount-award-settlement" => :claim_number,
      "mc-amount-award-attributed" => :other_case_description,
      "mc-method-resolution" => :malpractice_resolution_malpractice_resolution_method,
      "mc-date-settlement" => :case_closed_date,
      "mc-description-allegations" => :allegation_description,
      "defendant-options" => :primary_defendant_flag,
      "mc-defendant-number" => :number_other_codefendant,
      "mc-case-involvement" => :case_involvement,
      "mc-specific-responsibility" => :provider_role,
      "mc-description-alleged-patient" => :patient_injury_description,
      "mc-patient-outcome" => :patient_outcome,
      "has_injury_to_death" => :patient_died_flag,
      "has_npdb_case" => :npdb_case_flag
    }.freeze

    MILITARY_FIELD_MAP = {
      "military_enlist_base_of_service" => :branch,
      "mi-mrtd" => :discharge_rank,
      "military_enlist_data" => :start_date, 
      "military_discharge_data" => :end_date,
      "military_primary_base" => :last_location,
      "military_division" => :active_duty,
      "military_primary_base_location" => :branch_of_military, 
      "military_status" => :type_of_discharge, 
      "military_appointed_date" => :reserve_separation_month, 
      "honorably_discharge" => :honorable_discharge_flag, 
      "military_discharge_reason" => :discharge_explanation,
      "military_court_martialed" => :court_martial_flag,
      "court_martialed_reason" => :court_martial_explanation,
      "military_reserve" => :reserve_guard_flag,
      "served_in_military" => :us_military_service
    }.freeze

    EMPLOYMENT_FIELD_MAP = {
      "edc-employment-location" => :country,
      "edc-practice-employer-name" => :employer_name,
      "no_longer_in_business" => :comments,
      "edc-first-name" => :contact_first_name,
      "edc-last-name" => :contact_last_name,
      "edc-address-line1" => :address,
      "edc-address-line2" => :additional_address,
      "edc-city" => :city,
      "edc-zipcode" => :zip,
      "edc-telephone-number" => :phone_number,
      "edc-ext" => :mail_stop,
      "edc-email" => :email,
      "edc-mcde" => :comments, 
      "edc-contact-method" => :contact_method,
      "edc-position-held" => :position,
      "edc-start-date" => :from_date,
      "edc-end-date" => :to_date,
      "until_present" => :show_on_tickler, 
      "edc_collab" => :comments,  
      "co-first-name" => :comments,
      "co-middle-name" => :comments,
      "co-last-name" => :comments,
      "co-suffix" => :comments,
      "co-degree" => :comments,
      "state_abbr" => :comments,
      "co-physician-pln" => :comments,
      "co-medicare-number" => :comments,
      "co-npi-number" => :comments
    }.freeze

    TIME_GAP_FIELD_MAP = {
      "gap_start_date"       => :start_date,
      "gap_end_date"         => :end_date,
      "gap_reason"           => :gap_description,
      "gap_explanation"      => :gap_explanation
    }.freeze

    REFERENCE_FIELD_MAP = {
      "rf-first-name"                  => :first_name,
      "rf-middle-name"                => :middle_name,
      "rf-last-name"                  => :last_name,
      "rf-suffix"                     => :title,
      "rf-degree"                     => :degree_degree_abbreviation,
      "rf-specialty"                  => :specialty_specialty_name,
      "rf-contact-method"             => :reference_type_provider_type_abbreviation,
      "rf-address-line1"              => :address,
      "rf-address-line2"              => :address2,
      "rf-city"                       => :city,
      "rf-state"                      => :state,
      "rf-zipcode"                    => :postal_code,
      "rf-telephone-number"          => :phone_number,
      "rf-ext"                        => :phone_extension,
      "rf-fax"                        => :fax_number,
      "rf-does-not-have"             => :fax_number,
      "rf-mobile-number"             => :cell_phone_number,
      "rf-email-address"             => :email_address,
      "rf-association-start-date"    => :start_date,
      "rf-association-end-date"      => :end_date,
      "rf-association-until-present" => :end_date,
      "rf-relationship"              => :relationship
    }.freeze

    PROF_ORGANIZATION_MAPPING = {
      "prof_organization_name" => :prof_organization_name,
      "prof_org_effected_date" => :prof_org_effected_date,
      "prof_org_termination_date" => :prof_org_termination_date,
      "prof_org_until_current" => :prof_org_until_current
    }

    def initialize(source:, field_name:, value:, model_id:, model:)
      @source = source
      @field_name = field_name
      @value = value
      @model_id = model_id
      @model = model
    end

    def perform
      attest = @source.provider_personal_information&.provider_attest
      return { error: "Attest not found" } unless attest

      case @model
      when 'dea'
        map_and_save(DEA_FIELD_MAP, ProviderDea, :caqh_provider_deaid, attest)
      when 'cds'
        map_and_save(CDS_FIELD_MAP, ProviderCd, :caqh_provider_cdsid, attest)
      when 'licensure'
        save_licensure(attest)
      when 'medicare'
        map_and_save(MEDICARE_FIELD_MAP, ProviderMedicare, :caqh_provider_medicare_id, attest)
      when 'medicaid'
        map_and_save(MEDICAID_FIELD_MAP, ProviderMedicaid, :caqh_provider_medicaid_id, attest)
      when 'other_cert'
        map_and_save(OTHER_CERTIFICATION_FIELD_MAP, ProviderCertification, :caqh_provider_certification_id, attest)
      when 'training'
        map_and_save(TRAINING_FIELD_MAP, ProviderEducation, :caqh_provider_education_id, attest)
      when 'liability'
        map_and_save(LIABILITY_FIELD_MAP, ProviderInsuranceCoverage, :caqh_provider_insurance_id, attest)
      when 'malpractice'
        map_and_save(MALPRACTICE_FIELD_MAP, ProviderMalpracticeHistory, :caqh_provider_malpractice_id, attest)
      when 'military'
        map_and_save(MILITARY_FIELD_MAP, ProviderMilitary, :caqh_provider_military_id, attest)
      when 'employment'
        map_and_save(EMPLOYMENT_FIELD_MAP, ProviderEmployment, :caqh_provider_employment_id, attest)
      when 'employment_gap'
        map_and_save(TIME_GAP_FIELD_MAP, ProviderTimeGap, :caqh_provider_time_gap_id, attest)  
      when 'prof_references'
        map_and_save(REFERENCE_FIELD_MAP, ProviderReference, :caqh_provider_reference_id, attest)
      when 'prof_organization'
        map_and_save(PROF_ORGANIZATION_MAPPING, ProfessionalOrganization, :caqh_provider_professional_organization_id, attest)   
      else
        { error: "Invalid model type: #{@model}" }
      end
    end

    private

    def map_and_save(field_map, model_class, foreign_key, attest)
      attribute = field_map[@field_name]
      return { error: "Invalid field name: #{@field_name}" } unless attribute

      record = model_class.find_or_initialize_by(foreign_key => @model_id) do |r|
        r.provider_attest_id = attest.id

        # Set required defaults on initialization (creation only)
        r.prof_org_effected_date ||= Date.today if model_class.name == "ProfessionalOrganization"
        r.prof_org_termination_date ||= Date.today if model_class.name == "ProfessionalOrganization"
      end

      record.assign_attributes(attribute => @value)

      if record.save(validate: false)
        { status: "saved", id: record.id }
      else
        { error: record.errors.full_messages }
      end
    end

    def save_licensure(attest)
      attribute = LICENSURE_FIELD_MAP[@field_name]
      return { error: "Invalid licensure field: #{@field_name}" } unless attribute

      if attribute == :state_id
        state = State.find_by(alpha_code: @value.upcase) || State.find_by(name: @value.titleize)
        return { error: "State not found: #{@value}" } unless state
        @value = state.id
      end

      record = ProviderLicensure.find_or_initialize_by(provider_attest_id: attest.id)
      record.assign_attributes(attribute => @value)

      if record.save(validate: false)
        { status: "saved", id: record.id }
      else
        { error: record.errors.full_messages }
      end
    end

    def normalize_value(attribute, value)
      if attribute == :program_completed_flag
        value == "false" ? false : true
      else
        value
      end
    end
  end
end

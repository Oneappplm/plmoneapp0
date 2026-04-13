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
      "other_certification_type" => :certification_type,
      "other_certification_number" => :certification_number,
      "other-certification-issue-date" => :initial_certification_date,
      "other_certification_expiration_date" => :certification_expiration_date,
      "other_certification_not_expire" => :does_not_expire
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
      "lf-self-insured-policy-number" => :policy_number,
      "lf-self-insured-policy-name" => :policy_holder,
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

    CREDENTIALING_CONTACT_FIELD_MAP = {
      "cc-preferred-contact"         => :contact_method,
      "cc-first-name"                => :firstname,
      "cc-middle-name"              => :middlename,
      "cc-last-name"                 => :lastname,
      "cc-title"                     => :title,
      "cc-suffix"                    => :suffix_of_credentialing_contact,
      "cc-telephone-number"         => :phone_number,
      "cc-fax-number"               => :fax_number,
      "cc-email-address"            => :email_address,
      "cc-address-line1"            => :address,
      "cc-address-line2"            => :additional_address,
      "cc-suite"                    => :suit_or_apt,
      "cc-city"                     => :city,
      "cc-county"                   => :county,
      "cc-state"                    => :state_or_province,
      "cc-zipcode"                  => :zipcode,
      "cc-country"                  => :country
    }

    PRACTICE_MAPPING = {
      "practice_name" => :practice_name,
      "practice_primary_location" => :is_primary_location,
      "practice_address_line_1" => :address,
      "practice_address_line_2" => :address2,
      "practice_city" => :city,
      "practice_county" => :county,
      "dco_state" => :state,
      "practice_zip_code" => :zip,
      "practice_telephone_number" => :phone_number,
      "practice_telephone_ext" => :phone_extension,
      "practice_fax_number" => :fax_number,
      "offer_telehealth" => :fax_number,
      "practice_type" => :practice_type,
      "practice_name_on_w-9" => :group_name,
      "practice_tax_id" => :tax_id,
      "practice_name_affiliated_tax_id" => :name_affiliated_with_tax_id,
      "practice_group_npi" => :group_npi,
      "practice_group_medicare_number" => :medicare_number,
      "practice_limitations_field" => :has_practice_limit_age,
      "practice_location_interpreter" => :interpreter_available_flag,
      "ada_accessibility" => :ada_accessibility,
      "services_disabled" => :disabled_other,
      "public_transport" => :public_transportation,
      "gender_treatment" => :iv_hydration_treatments,
      "practice_laboratory_services" => :is_laboratory_services,
      "practice_clia_waiver" => :clia_waiver,
      "practice_clia_certificate" => :clia_certificate,
      "practice_clia_radiology" => :radiology_services,
      "midlevel_practitioner_field" => :any_allied_health_practitioner,
      "radiology_services" => :radiology_services,
      "practice_partner" => :partners_flag,
      "practice_partners_cover" => :any_cover_practitioner,
    }.freeze
    PRACTICE_LOCATION_MAPPING = {
      "practice_group_npi" => :group_npi_number,
      "practice_group_npi_effective_date" => :group_npi_number_effective_date,
      "contact_office_first_name" => :contact_first_name,
      "contact_office_last_name" => :contact_last_name,
      "contact_office_telephone_number" => :contact_phone_number,
      "contact_office_fax_number" => :contact_fax_number,
      "contact_office_email" => :contact_email,
      "monday_practice_hours_from" => :monday_time_start,
      "monday_practice_hours_to" => :monday_time_end,
      "practice_hours_split_day_Monday" => :monday_split_day,
      "practice_hours_closed_Monday" => :monday_closed,
      "tuesday_practice_hours_from" => :tuesday_time_start,
      "tuesday_practice_hours_to" => :tuesday_time_end,
      "practice_hours_closed_Tuesday" => :tuesday_closed,
      "practice_hours_split_day_Tuesday" => :tuesday_split_day,
      "wednesday_practice_hours_from" => :wednesday_time_start,
      "wednesday_practice_hours_to" => :wednesday_time_end,
      "practice_hours_split_day_Wednesday" => :wednesday_split_day,
      "practice_hours_closed_Wednesday" => :wednesday_closed,
      "thursday_practice_hours_from" => :thursday_time_start,
      "thursday_practice_hours_to" => :thursday_time_end,
      "practice_hours_split_day_Thursday" => :thursday_split_day,
      "practice_hours_closed_Thursday" => :thursday_closed,
      "friday_practice_hours_from" => :friday_time_start,
      "friday_practice_hours_to" => :friday_time_end,
      "practice_hours_split_day_Friday" => :friday_split_day,
      "practice_hours_closed_Friday" => :friday_closed,
      "saturday_practice_hours_from" => :saturday_time_start,
      "saturday_practice_hours_to" => :saturday_time_end,
      "practice_hours_split_day_Saturday" => :saturday_split_day,
      "practice_hours_closed_Saturday" => :saturday_closed,
      "sunday_practice_hours_from" => :sunday_time_start,
      "sunday_practice_hours_to" => :sunday_time_end,
      "practice_hours_split_day_Sunday" => :sunday_split_day,
      "practice_hours_closed_Sunday" => :sunday_closed,
      "practice_comments" => :comment,
      "practice_patient_phone" => :patient_appointment_phone_number,
      "practice_patient_phone_ext" => :patient_appointment_phone_extension,
      "phone_coverage_field" => :coverage24x7_flag,
      "practice_phone_coverage_type" => :telephone_coverage_type,
      "practice_after_hour_phone_number" => :telephone_number_after_hours,
      "practice_after_hour_phone_number_ext" => :telephone_number_ext,
      "practice_status" => :open_practice_status,
      "practice_patient_age_not_applicable" => :pa_min_max_not_applicable,
      "practice_patient_min_age" => :pa_minimum_age,
      "practice_patient_max_age" => :pa_maximum_age,
      "practice_gender_limitation" => :pa_gender_limitations,
      "practice_patient_other_limits" => :pa_other_limitations,
      "readonly_foreign_language_speak" => :languages_speak,
      "readonly_foreign_language_write" => :languages_write,
      "readonly_foreign_language_interprets" => :interpreters_available,
      "practice_fda_radiology" => :radiology_services_fda,
      "practice_administered_anesthesia" => :anesthesia_administered,
    }
    PRACTICE_ASSOCIATE_MAPPING = {
      "practice_partners_first_name" => :associate_first_name,
      "practice_partners_last_name" => :associate_last_name,
      "practice_partners_middle_name" => :associate_middle_initial,
      "practice_partners_degree" => :degree_degree_abbreviation,
      "practice_partners_license_number" => :license_number,
      "practice_partners_cover" => :coverage_flag,
      "practice_partners_specialty" => :provider_type_provider_type_abbreviation,
      "practice_midlevel_state" => :state
    }
    COVERING_PRACTITIONER_MAPPING = {
      "cv-first-name"         => :practitioner_name,
      "cv-middle-name"        => :practitioner_name,
      "cv-last-name"          => :practitioner_name,
      "cv-address-line1"      => :address,
      "cv-address-line2"      => :address2,
      "cv-city"               => :city,
      "state_abbr_1"          => :state,
      "cv-zipcode"            => :zipcode,
      "cv-telephone-number"   => :phone_number,
      "cv-fax-number"         => :fax_number,
      "cv-email-address"      => :email_address,
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
        map_and_save(OTHER_CERTIFICATION_FIELD_MAP, Certification, :caqh_provider_certification_id, attest)
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
      when 'cred_contact'
        map_and_save(CREDENTIALING_CONTACT_FIELD_MAP, ProviderPersonalInformationCredentialingContact, :caqh_provider_cred_contact_id, @source.provider_personal_information.id)
      when 'prac_general_info'
        map_and_save(PRACTICE_MAPPING, PracticeInformation, :caqh_provider_practice_id, attest)
      when 'prac_location_info'
        map_and_save(PRACTICE_LOCATION_MAPPING, PracticeLocation, :practice_information_id, attest)
      when 'prac_associate_info'
        map_and_save(PRACTICE_ASSOCIATE_MAPPING, PracticeAssociate, :practice_information_id, attest)
      when 'covering_prac_info'
        map_and_save(COVERING_PRACTITIONER_MAPPING, CoveringPractitioner, :practice_information_id, attest)
      else
        { error: "Invalid model type: #{@model}" }
      end
    end

    private

    def map_and_save(field_map, model_class, foreign_key, attest)
      attribute = field_map[@field_name]
      return { error: "Invalid field name: #{@field_name}" } unless attribute

      if model_class.name != 'PracticeLocation' || model_class.name != 'PracticeAssociate' || model_class.name != 'CoveringPractitioner'
        record =
          if model_class == ProviderInsuranceCoverage
            model_class.find_or_initialize_by(provider_attest_id: attest.id)
          else
            model_class.find_or_initialize_by(foreign_key => @model_id)
          end

        if record.has_attribute?(:provider_attest_id)
          record.provider_attest_id ||= attest.id
        elsif record.has_attribute?(:provider_personal_information_id)
          record.provider_personal_information_id ||= attest.provider_personal_information_id
        end

        if model_class.name == "ProfessionalOrganization"
          record.prof_org_effected_date ||= Date.today
          record.prof_org_termination_date ||= Date.today
        end

        record.assign_attributes(attribute => @value)

        if record.save(validate: false)
          # 📌 Create a corresponding PracticeLocation when PracticeInformation is saved
          if model_class.name == "PracticeInformation"
            begin
              pl = PracticeLocation.find_or_initialize_by(practice_information_id: record.id)
              pl.save(validate: false)
            rescue => e
              Rails.logger.error "❌ PracticeLocation creation failed: #{e.message}"
              return { error: "Failed to create PracticeLocation: #{e.message}" }
            end
          end

          return { status: "saved", id: record.id }
        else
          return { error: record.errors.full_messages }
        end

      # 🔁 Special handling for PracticeLocation updates
      else
        begin
          pinfo = attest.provider_personal_informations.last

          practice_info = pinfo.practice_informations.last

          unless practice_info
            return { error: "No PracticeInformation found for provider ##{@model_id}" }
          end

          record = case model_class.name
             when 'PracticeLocation'
               PracticeLocation.find_or_initialize_by(practice_information_id: practice_info.id)
             when 'PracticeAssociate'
               PracticeAssociate.find_or_initialize_by(practice_information_id: practice_info.id)
             when 'CoveringPractitioner'
               CoveringPractitioner.find_or_initialize_by(practice_information_id: practice_info.id)
             else
               return { error: "Unknown model #{@model}" }
             end
          record.assign_attributes(attribute => @value)
        
          if record.save(validate: false)
            return { status: "updated", id: record.id }
          else
            return { error: record.errors.full_messages }
          end

        rescue => e
          Rails.logger.error "❌ PracticeLocation update failed: #{e.message}"
          return { error: "PracticeLocation update failed: #{e.message}" }
        end
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

# app/services/provider_sources/autosave_service.rb
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
    }
    MEDICADE_FIELD_MAP = {
      "participating_medicaid_number" => :medicaid_number,
      "participating_medicaid_state" => :state,
    }
    OTHER_CERTIFICATION_FIELD_MAP = {
      "other_cert_field" => :certification_flag,
      "other_certification_type" => :certification_type,
      "other_certification_number" => :certification_number,
      "other_certification_state" => :state,
      "other-certification-issue-date" => :obtained_date,
      "other_certification_expiration_date" => :expiration_date,
      "other_certification_not_expire" => :certification_status
    }

    def initialize(source:, field_name:, value:, model_id:, model:)
      @source = source
      @field_name = field_name
      @value = value
      @model_id = model_id
      @model = model
    end

    def perform
      attest = @source.provider_personal_information.provider_attest
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

		  # Special case: if assigning a state_id from a name like "HI"
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
  end
end

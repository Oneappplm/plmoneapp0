class Api::V1::ProvidersController < Api::V1::BaseController
	def index
		render json: Provider.unscoped.where(api_token: bearer_token).all
	end

	def create
		provider	= Provider.new(provider_params)
		provider.api_token = bearer_token
		if provider.save!
			render json: provider.to_json, status: 201
		else
			render json: { errors: provider.errors.to_json }, status: 422
		end
	end

	protected
	def provider_params
		params.require(:provider).permit(
				:first_name,
				:middle_name,
				:last_name,
				:suffix,
				:gender,
				:birth_date,
				:practitioner_type,
				:ssn,
				:npi,
				:caqhid,
				:caqh_attestation_date,
				:caqh_pdf,
				:caqh_pdf_date_received,
				:nccpa_number,
				:dea_number,
				:dea_license_effective_date,
				:dea_license_expiration_date,
				:dco,
				:dco_file,
									:enrollment_group_id,
				:address_line_1, :address_line_2, :city, :state, :telephone_number, :ext, :email_address, :provider_hire_date_seeing_patient, :effective_date_seeing_patient,
				:medicare_provider_number, :medicaid_provider_number, :tricare_provider_number, :admitting_privileges, :revalidation, :employed_by_other, :supervised_by_psychologist,
				:medical_school_name, :medical_school_address, :graduation_date, :school_certificate, :caqh_username, :caqh_password, :caqh_state, :caqh_app, :caqh_payor,
				:telehealth_license_number, :board_certification_number, :dea_registration_state, :pa_license_effective_date, :pa_license_expiration_date, :name_admitting_physician,
				:facility_location, :facility_name, :admitting_facility_address_line1, :admitting_facility_address_line2, :admitting_facility_city, :admitting_facility_zip_code, :admitting_facility_arrangments
		)
	end
end
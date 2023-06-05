class ProvidersController < ApplicationController
	before_action :set_provider, only: [:show, :edit, :update, :destroy]
	def index
    @providers = Provider.all
	end

	def new
			@provider = Provider.new
			build_associations
	end

	def edit
		build_associations
	end

  def overview
  end

	def create
			@provider = Provider.new(provider_params)
			@provider.encoded_by = current_user&.full_name
			if @provider.save
					redirect_to providers_path
			else
				 build_associations
					render :new
			end
	end

	def update
		if @provider.update(provider_params)
				 @provider.update updated_by: current_user&.full_name
				redirect_to providers_path, notice: 'Provider was successfully updated.'
		else
			 build_associations
				render :edit
		end
end

	def destroy
			if @provider.destroy
				redirect_to providers_path, notice: 'Successfully deleted'
			else
				redirect_to providers_path, alert: 'Something went wrong'
			end
	end

  def show
    @providers = Provider.all
    @provider = Provider.find(params[:id])
    @comment = EnrollmentComment.new
    @comment.provider = @provider
    @comment.user = current_user
  end

	private

	def set_provider
			@provider = Provider.find(params[:id])
	end

	def build_associations
    # to jayson added if condition here to prevent extra build of attr fields on edit
		@provider.taxonomies.build if @provider.taxonomies.blank?
		@provider.licenses.build if @provider.licenses.blank?
		@provider.np_licenses.build if @provider.np_licenses.blank?
		@provider.rn_licenses.build if @provider.rn_licenses.blank?
	end

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
					:facility_location, :facility_name, :admitting_facility_address_line1, :admitting_facility_address_line2, :admitting_facility_city, :admitting_facility_zip_code, :admitting_facility_arrangments,
					taxonomies_attributes: [:id, :taxonomy_code, :specialty, :_destroy],
					licenses_attributes: [:id, :license_number, :license_effective_date, :license_expiration_date, :_destroy],
					np_licenses_attributes: [:id, :np_license_number, :np_license_effective_date, :np_license_expiration_date, :_destroy],
					rn_licenses_attributes: [:id, :rn_license_number, :rn_license_effective_date, :rn_license_expiration_date, :_destroy]
			)
	end
end

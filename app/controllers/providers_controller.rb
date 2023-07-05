class ProvidersController < ApplicationController
	before_action :set_provider, only: [:show, :edit, :update, :destroy]
	def index
			@providers = if params[:user_search].present?
						Provider.search(params[:user_search]).paginate(per_page: 10, page: params[:page] || 1)
				else
						Provider.paginate(per_page: 10, page: params[:page] || 1)
				end
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
		# @provider.taxonomies.build if @provider.taxonomies.blank?
		@provider.licenses.build if @provider.licenses.blank?
		@provider.np_licenses.build if @provider.np_licenses.blank?
		@provider.rn_licenses.build if @provider.rn_licenses.blank?
		@provider.service_locations.build if @provider.service_locations.blank?
    @provider.pa_licenses.build if @provider.pa_licenses.blank?
    @provider.dea_licenses.build if @provider.dea_licenses.blank?
    @provider.mn_licenses.build if @provider.mn_licenses.blank?
    @provider.mccs.build if @provider.mccs.blank?
    @provider.mn_medicaids.build if @provider.mn_medicaids.blank?
    @provider.medicaids.build if @provider.medicaids.blank?
    @provider.wi_medicaids.build if @provider.wi_medicaids.blank?
    @provider.medicares.build if @provider.medicares.blank?
    @provider.cnp_licenses.build if @provider.cnp_licenses.blank?
    @provider.ins_policies.build if @provider.ins_policies.blank?

  end

	def provider_params
			params.require(:provider).permit(
					:first_name,
					:middle_name,
					:last_name,
					:suffix,
					:gender,
					:birth_date,
					:birth_city,
					:birth_state,
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
          :caqh_current_reattestation_date,
          :caqh_reattest_completed_by,
          :caqh_question,
          :caqh_answer,
          :caqh_notes,
          :taxonomy,
          :specialty,
          :provider_effective_date,
          :board_certified,
					:address_line_1, :address_line_2, :city, :zip_code, :state_id, :telephone_number, :ext, :email_address, :provider_hire_date_seeing_patient, :effective_date_seeing_patient,
					:medicare_provider_number, :medicaid_provider_number, :tricare_provider_number, :telehealth_providers, :admitting_privileges, :revalidation, :employed_by_other, :supervised_by_psychologist,
					:medical_school_name, :medical_school_address, :graduation_date, :school_certificate, :caqh_username, :caqh_password, :caqh_state, :caqh_app, :caqh_payor,
					:telehealth_license_number, :board_certification_number, :dea_registration_state, :pa_license_effective_date, :pa_license_expiration_date, :name_admitting_physician,
					:facility_location, :facility_name, :admitting_facility_address_line1, :admitting_facility_address_line2, :admitting_facility_city, :admitting_facility_state, :admitting_facility_zip_code, :admitting_facility_arrangments, :state_license_copy_file, :dea_copy_file, :w9_form_file, :certificate_insurance_file, :drivers_license_file, :board_certification_file, :caqh_app_copy_file, :cv_file, :telehealth_license_copy_file,
					# taxonomies_attributes: [:id, :taxonomy_code, :specialty, :_destroy],
					licenses_attributes: [:id, :license_number, :license_effective_date, :license_expiration_date, :state_id, :_destroy],
					np_licenses_attributes: [:id, :np_license_number, :np_license_effective_date, :np_license_expiration_date, :_destroy],
					rn_licenses_attributes: [:id, :rn_license_number, :rn_license_effective_date, :rn_license_expiration_date, :_destroy],
					service_locations_attributes: [:id, :primary_service_non_office_area, :primary_service_location_apps, :primary_service_zip_code, :primary_service_office_email, :primary_service_fax, :primary_service_office_website, :primary_service_crisis_phone, :primary_service_location_other_phone, :primary_service_appt_scheduling, :primary_service_interpreter_language, :primary_service_telehealth_only_state],
          pa_licenses_attributes: [:id, :pa_license_number, :pa_license_effective_date, :pa_license_expiration_date, :_destroy],
          dea_licenses_attributes: [:id, :dea_license_number, :dea_license_effective_date, :dea_license_expiration_date, :state_id, :_destroy],
          mn_licenses_attributes: [:id, :mn_license_number, :mn_license_expiration_date, :_destroy],
          mccs_attributes: [:id, :mcc_username, :mcc_password, :mcc_electronic_signature_code, :_destroy],
          mn_medicaids_attributes: [:id, :mn_medicaid_number, :mn_medicaid_username, :password, :question, :answer, :_destroy],
          medicaids_attributes: [:id, :effective_date, :reval_date, :notes, :_destroy],
          wi_medicaids_attributes: [:id, :wi_medicaid, :wi_medicaid_username, :password, :question, :answer, :notes, :_destroy],
          medicares_attributes: [:id, :ptan_number, :medicare_username, :password, :question, :answer, :effective_date, :reval_date, :notes, :_destroy],
          cnp_licenses_attributes: [:id, :cnp_license_number, :effective_date, :expiration_date, :_destroy],
          ins_policies_attributes: [:id, :ins_policy_number, :effective_date, :expiration_date, :_destroy],
			)
	end
end
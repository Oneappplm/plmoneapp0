require 'open-uri' 
require 'zip'  
class ProvidersController < ApplicationController
	before_action :set_provider, only: [:edit, :update, :destroy, :update_from_notifications]
	before_action :set_overview_details, only: [:overview]

  def index
		if params[:user_search].present?
			search_term = params[:user_search].strip.downcase

			@providers = Provider.unscoped
				.select("CASE WHEN first_name = '' THEN NULL ELSE first_name END as f,
								 CASE WHEN last_name = '' THEN NULL ELSE last_name END as l,
								 CASE WHEN middle_name = '' THEN NULL ELSE middle_name END as m, *")
				.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(middle_name) LIKE :search", search: "%#{search_term}%")
		else
			@providers = if current_user.provider?
				# Provider.where(id: current_user.accessible_provider)
				accessible_provider_id = current_user.accessible_provider.blank? ? 0 : current_user.accessible_provider

				Provider.unscoped
				.select("CASE WHEN first_name = '' THEN NULL ELSE first_name END as f,
								 CASE WHEN last_name = '' THEN NULL ELSE last_name END as l,
								 CASE WHEN middle_name = '' THEN NULL ELSE middle_name END as m, *")
				.where("id = ?", accessible_provider_id)
				.all
			else
				Provider.unscoped
				.select("CASE WHEN first_name = '' THEN NULL ELSE first_name END as f,
								 CASE WHEN last_name = '' THEN NULL ELSE last_name END as l,
								 CASE WHEN middle_name = '' THEN NULL ELSE middle_name END as m, *")
				.all
			end
		end

		if !current_user.can_access_all_groups? && !current_user.super_administrator? && !current_user.provider? && !sprout_staff_admin(current_user)
			if current_user.administrator? && current_user.assigned_access_only? && current_setting.groups? 
				@providers = @providers.where(admin_id: current_user.id)
			else
				@providers = @providers.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id))
			end
		end



			@providers = @providers.reorder("f asc NULLS last", "m asc NULLS last", "l asc NULLS last")
			@providers_without_pagination =	@providers

			@providers = @providers.paginate(per_page: 10, page: params[:page] || 1)

			@providers = @providers.reorder("f asc NULLS last", "m asc NULLS last", "l asc NULLS last").paginate(per_page: 10, page: params[:page] || 1)
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
		# render json: @provider and return
		@provider.encoded_by = current_user&.full_name
		@provider.updated_by = current_user&.full_name
		if @provider.save
			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Add Provider",
				body: "#{@provider.encoded_by} added a new provider: #{@provider.provider_name}"
			).send_system_notification.deliver_later

			# Only send notification to those that are related to the provider's group
			users = User.includes(:users_enrollment_groups).where(users_enrollment_groups: { id: @provider.enrollment_group_id })

      ProviderEmailCreationNotification.with(provider_full_name: @provider.fullname, provider_id: @provider.id).deliver(users)
      ProviderCreationNotification.with(provider_full_name: @provider.fullname, provider_id: @provider.id).deliver(users)
			redirect_to providers_path, notice: 'Provider has been successfully created.'
		else
			build_associations
			render :new
		end
	end

  def update_from_notifications
    submission = @provider.create_missing_field_submission
    params[:provider].each do |key, value|
        submission.create_missing_field_submission_data(key,value) if !key.include?('_attributes') && key != 'id' && !value.blank?
        if key.include?('_attributes')
          params[:provider][key.to_sym].each do |key2,value2|
            submission.create_missing_field_submission_data(key2,value2,key) if key2 != 'id' && !value2.blank?
          end
        end
     end

		ProvidersMissingFieldSubmissionNotification.with(submitted_fields: @submitted_fields, provider_full_name: @provider.fullname, provider_id: @provider.id).deliver(User.agents) if submission

    redirect_to enrollment_client_path(@provider, mode: 'notifications'), notice: 'Provider was successfully updated.'
  end

	def update
		@provider.assign_attributes(provider_params)
		@provider.remove_state_license_copies
		@provider.remove_dea_copies
		@provider.remove_w9_form_copies
		@provider.remove_certificate_insurance_copies
		@provider.remove_driver_license_copies
		@provider.remove_board_certification_copies
		@provider.remove_caqh_app_copies
		@provider.remove_cv_copies
		@provider.remove_telehealth_license_copies

		@old_provider_data = Provider.find(params[:id])
	  @new_provider_data = @provider

    profile_update(@old_provider_data,@new_provider_data)

  	if @provider.save(validate: false)
			@provider.update_columns updated_by: current_user&.full_name

			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Edit Provider",
				body: "#{@provider.updated_by} updated a provider: #{@provider.provider_name}"
			).send_system_notification.deliver_later


			if params[:from_notifications].present?
        submission = @provider.create_missing_field_submission
        if submission
          params[:provider].each do |key,value|
            submission.create_missing_field_submission_data(key,key, 'upload') if !key.include?('_attributes') && key != 'id'
          end
          ProvidersMissingFieldSubmissionNotification.with(submitted_fields: @submitted_fields, provider_full_name: @provider.fullname, provider_id: @provider.id).deliver(User.agents)
        end
        redirect_to enrollment_client_path(@provider, mode: 'notifications'), notice: 'Provider was successfully updated.'
      else
        redirect_to providers_path, notice: 'Provider was successfully updated.'
		  end
    else
			 build_associations
				render :edit
		end
	end

	def profile_update(old_data, new_data)
		  changed_attributes = []

		  old_data.attributes.each do |attribute, old_value|
		    new_value = new_data[attribute]
		    if old_value != new_value
		      changed_attributes << attribute.to_s
		    end
		  end

	    changed_attributes

		users = User.includes(:users_enrollment_groups).where(users_enrollment_groups: { id: @provider.enrollment_group_id })

		EnrollmentChangesNotification.with(changed_attributes_array: changed_attributes, provider_full_name: old_data.fullname).deliver(users)
	end
	def destroy
		if @provider.destroy
			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Delete Provider",
				body: "#{current_user&.full_name} deleted a provider: #{@provider.provider_name}"
			).send_system_notification.deliver_later
			redirect_to providers_path, notice: 'Successfully deleted'
		else
			redirect_to providers_path, alert: 'Something went wrong'
		end
	end

  def show
    @providers = Provider.all
		if !current_user.can_access_all_groups? && !current_user.super_administrator? && !sprout_staff_admin(current_user)
			@providers = @providers.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id))
		end
		if !current_user.can_access_all_groups? && !current_user.super_administrator? && !sprout_staff_admin(current_user)
    	@provider = Provider.includes(:group).where(group: { id: current_user.enrollment_groups.pluck(:id) }).where(id: params[:id] || params[:provider_id]).last
			if !@provider.present?
				redirect_back(fallback_location: root_path, alert: "You don't have access to the provider.")
			end
		else
			@provider = Provider.find(params[:id] || params[:provider_id])
		end
    @comment = EnrollmentComment.new
    @comment.provider = @provider
    @comment.user = current_user
    if @provider
      @time_line = @provider.time_lines.new
    end
  end

	def download_all_pdfs
    @provider = Provider.find(params[:id])

    documents = ['state_license_copies', 'dea_copies', 'w9_form_copies', 'certificate_insurance_copies', 'driver_license_copies', 'board_certification_copies', 'caqh_app_copies', 'cv_copies', 'telehealth_license_copies', 'school_certificate']

    temp_zip = Tempfile.new("all_documents.zip")

    # Create a ZIP file
    Zip::OutputStream.open(temp_zip) do |zip|
      documents.each do |doc|
        begin
          if @provider.send(doc).present?
            if doc == "school_certificate"
              url = @provider.send(doc).url
              Rails.logger.info "Opening URL: #{url}"  # Debug log
              file_content = URI.open(url).read
              zip.put_next_entry("#{doc}.pdf")
              zip.write(file_content)
            else
              @provider.send(doc).each_with_index do |file, idx|
                url = file.url
                Rails.logger.info "Opening URL: #{url}"  # Debug log
                file_content = URI.open(url).read
                zip.put_next_entry("#{doc}_#{idx + 1}.pdf")
                zip.write(file_content)
              end
            end
          end
        rescue => e
          Rails.logger.error "Error processing #{doc}: #{e.message}"
        end
      end
    end

    temp_zip.rewind  # Rewind the file for reading

    # Send the zip file to the browser
    send_data temp_zip.read, filename: 'all_documents.zip', type: 'application/zip', disposition: 'attachment'

    temp_zip.close
    temp_zip.unlink  # Ensure the temporary file is deleted after download
  end

  def create_peer_recommendation
    selected_ids = params[:selected_ids][0].split(',').map(&:to_i)
  
    ActiveRecord::Base.transaction do
      selected_ids.each do |provider_id|
        peer_recommendation = PeerRecommendation.new(
          provider_id: provider_id,
          allow_recommendation: params[:allow_recommendation],
          recommendation: params[:recommendation],
          document: params[:document],
          notes: params[:notes]
        )
  
        # Rollback transaction if any  peer recommendation fails to save
        unless peer_recommendation.save
          raise ActiveRecord::Rollback
        end
      end
    end
  
    redirect_to providers_path, notice: 'Recommendation(s) submitted successfully.'
  rescue ActiveRecord::Rollback
    redirect_to providers_path, alert: 'An error occurred while creating Recommendation(s). Please try again.'
  end
  
	

		def document_deleted_logs
			provider = Provider.find_by(id: params[:provider_id])

			deleted_notes = provider.present?	? provider.deleted_document_logs.map {	|log| log.deleted_notes } : []

			render json: {
				results: deleted_notes
			}
		end

		def delete_document
			provider = Provider.find(params[:providerid])
			key = params[:key]
			note = params[:note]
			provider.send("remove_#{key}!")
			if provider.save!
				provider.deleted_document_logs.create(
					deleted_by: current_user&.full_name,
					deleted_at: Time.now,
					note: note,
					document_key: key
				)
				render json:	{ success: true }
			else
				render	json:	{ success: false }
			end
		end

	private

	def set_provider
		@provider = Provider.find(params[:id] || params[:provider_id])
	end

	def build_associations
    # to jayson added if condition here to prevent extra build of attr fields on edit
	# @provider.taxonomies.build if @provider.taxonomies.blank?
	# @provider.mn_licenses.build if @provider.mn_licenses.blank?
    # @provider.mccs.build if @provider.mccs.blank?
    # @provider.mn_medicaids.build if @provider.mn_medicaids.blank?
    # @provider.medicaids.build if @provider.medicaids.blank?
  	# @provider.wi_medicaids.build if @provider.wi_medicaids.blank?
    # @provider.medicares.build if @provider.medicares.blank?
	# @provider.ins_policies.build if @provider.ins_policies.blank?
	# @provider.np_licenses.build if @provider.np_licenses.blank?
	@provider.dea_licenses.build if @provider.dea_licenses.blank?
	@provider.licenses.build if @provider.licenses.blank?
	@provider.rn_licenses.build if @provider.rn_licenses.blank?
	@provider.service_locations.build if @provider.service_locations.blank?
	@provider.pa_licenses.build if @provider.pa_licenses.blank?
	@provider.cnp_licenses.build if @provider.cnp_licenses.blank?
	@provider.cds_licenses.build if @provider.cds_licenses.blank?
	@provider.board_certifications.build if @provider.board_certifications.blank?
	payer_login = @provider.payer_logins.build if @provider.payer_logins.blank?
	payer_login.questions.build if payer_login
	@provider.work_history_providers.build if @provider.work_history_providers.blank?
end


  def set_overview_details
    if current_user.can_access_all_groups? || current_user.super_administrator? || sprout_staff_admin(current_user)
      @providers_with_missing_details ||= Provider.with_missing_required_fields.count
      @providers_with_missing_documents ||= Provider.with_missing_required_docs.count
    else
      @providers_with_missing_details ||= Provider.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).with_missing_required_fields.count
      @providers_with_missing_documents ||= Provider.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).with_missing_required_docs.count
    end
  end

	def provider_params
			params.require(:provider).permit(
					:admin_id,
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
					# dco is to be removed
					:dco,
					:dcos,
					:dco_file,
					:enrollment_group_id,
					:secondary_enrollment_group_id,
					:secondary_primary_location,
					:secondary_dcos,
					:board_name,
					:board_certificate_number,
					:board_effective_date,
					:board_recertification_date,
					:board_expiration_date,
					:prof_medical_school_name,
					:prof_medical_school_address,
					:prof_medical_school_city,
					:prof_medical_school_country,
					:prof_medical_school_state_id,
					:prof_medical_school_zipcode,
					:prof_medical_start_date,
					:prof_medical_school_degree_awarded,
					:prof_liability_carrier_name,
					:prof_liability_self_insured,
					:prof_liability_address,
					:prof_liability_city,
					:prof_liability_state_id,
					:prof_liability_zipcode,
					:prof_liability_orig_effective_date,
					:prof_liability_effective_date,
					:prof_liability_expiration_date,
					:prof_liability_coverage_type,
					:prof_liability_unlimited_coverage,
					:prof_liability_tail_coverage,
					:prof_liability_coverage_amount,
					:prof_liability_coverage_amount_aggregate,
					:prof_liability_policy_number,
					:caqh_current_reattestation_date,
					:caqh_reattest_completed_by,
					:caqh_question,
					:caqh_answer,
					:caqh_notes,
					:caqh_state,
					:taxonomy,
					:specialty,
					:provider_effective_date,
					:board_certified,
					:medical_license,
					:status,
					:end_date,
					:payer_login,
					:work_history_not_applicable,
					:work_history_explain,
					:license_state_number,
					:license_state_effective_date,
					:license_state_id,
					:license_state_expiration_date,
					:licensed_registered_state_id,
					:address_line_1, :address_line_2, :city, :zip_code, :state_id, :telephone_number, :ext, :email_address, :provider_hire_date_seeing_patient, :effective_date_seeing_patient,
					:medicare_provider_number, :medicaid_provider_number, :tricare_provider_number, :telehealth_providers, :admitting_privileges, :revalidation, :employed_by_other, :supervised_by_psychologist,
					:medical_school_name, :medical_school_address, :graduation_date, :school_certificate, :caqh_username, :caqh_password, :caqh_state, :caqh_app, :caqh_payor,
					:telehealth_license_number, :board_certification_number, :dea_registration_state, :pa_license_effective_date, :pa_license_expiration_date, :name_admitting_physician,
					:facility_location, :facility_name, :admitting_facility_address_line1, :admitting_facility_address_line2, :admitting_facility_city, :admitting_facility_state, :admitting_facility_zip_code, :admitting_facility_arrangments, :state_license_copy_file, :dea_copy_file, :w9_form_file, :certificate_insurance_file, :drivers_license_file, :board_certification_file, :caqh_app_copy_file, :cv_file, :telehealth_license_copy_file,
					:new_provider_notification,
					:notification_start_date,
					:welcome_letter_sent,
					:notification_enrollment_submit,
					:notification_services,
					:send_welcome_letter,
					:dea_not_applicable,
					:cds_not_applicable,
					:rn_not_applicable,
					:aprn_not_applicable,
					:state_not_applicable,
					:dea_explain,
					:cds_explain,
					:rn_explain,
					:cnp_explain,
					:license_explain,
					:board_cert_explain,
					:board_certificate_not_applicable,
					:board_specialty_type,
					:supervising_name,
					:supervising_npi,
					:primary_location,
					:welcome_letter_status, :welcome_letter_subject, :welcome_letter_message, :check_welcome_letter, :check_co_caqh, :check_mn_caqh_state_release_form, :check_mn_caqh_authorization_form, :check_caqh_standard_authorization,
					{ welcome_letter_attachments: [], state_license_copies: [], dea_copies: [], w9_form_copies: [], certificate_insurance_copies: [], driver_license_copies: [], board_certification_copies: [], caqh_app_copies: [], cv_copies: [], telehealth_license_copies: [] },
					#taxonomies_attributes: [:id, :taxonomy_code, :specialty, :_destroy],
					licenses_attributes: [:id, :license_number, :license_effective_date, :license_expiration_date, :state_id, :license_state_renewal_date, :no_state_license, :license_type, :_destroy],
					np_licenses_attributes: [:id, :np_license_number, :state_id, :np_license_effective_date, :np_license_expiration_date, :np_license_renewal_effective_date, :no_np_license, :_destroy],
					rn_licenses_attributes: [:id, :rn_license_number, :state_id, :rn_license_effective_date, :rn_license_expiration_date, :rn_license_renewal_effective_date, :no_rn_license, :_destroy],
					service_locations_attributes: [:id, :primary_service_non_office_area, :primary_service_location_apps, :primary_service_zip_code, :primary_service_office_email, :primary_service_fax, :primary_service_office_website, :primary_service_crisis_phone, :primary_service_location_other_phone, :primary_service_appt_scheduling, :primary_service_interpreter_language, :primary_service_telehealth_only_state],
					#pa_licenses_attributes: [:id, :pa_license_number, :state_id, :pa_license_effective_date, :pa_license_expiration_date, :pa_license_rcleaenewal_effective_date, :no_pa_license, :_destroy],
					dea_licenses_attributes: [:id, :dea_license_number, :dea_license_effective_date, :dea_license_expiration_date, :dea_license_renewal_effective_date, :state_id, :no_dea_license,  :_destroy],

					work_history_providers_attributes: [:id, :practice_name, :location, :start_date, :end_date, :reasone_of_leaving, :tax_id, :_destroy ],

					cds_licenses_attributes: [:id, :cds_license_number, :state_id, :cds_license_issue_date, :cds_license_expiration_date, :cds_renewal_effective_date, :no_cds_license, :_destroy],
					mn_licenses_attributes: [:id, :mn_license_number, :mn_license_expiration_date, :_destroy],
					mccs_attributes: [:id, :mcc_username, :password, :mcc_electronic_signature_code, :_destroy],
					mn_medicaids_attributes: [:id, :mn_medicaid_number, :mn_medicaid_username, :password, :question, :answer, :_destroy],
					medicaids_attributes: [:id, :effective_date, :reval_date, :notes, :_destroy],
					wi_medicaids_attributes: [:id, :wi_medicaid, :wi_medicaid_username, :password, :question, :answer, :notes, :_destroy],
					medicares_attributes: [:id, :ptan_number, :medicare_username, :password, :question, :answer, :effective_date, :reval_date, :notes, :_destroy],
					cnp_licenses_attributes: [:id, :cnp_license_number, :state_id, :effective_date, :expiration_date, :cnp_license_renewal_effective_date, :no_cnp_license, :_destroy],
					board_certifications_attributes: [:id, :bc_certification_number, :bc_board_name, :bc_effective_date, :bc_expiration_date, :bc_recertification_date, :bc_specialty_type, :_destroy],
					ins_policies_attributes: [:id, :ins_policy_number, :effective_date, :expiration_date, :_destroy],
					payer_logins_attributes: [:id, :enrollment_payer, :username, :password, :state_id, :notes, :cred_current_reattest_date, :cred_reattest_date, :_destroy, questions_attributes: [:id, :question, :answer]]
			)
	end
end
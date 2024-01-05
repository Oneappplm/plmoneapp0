class EnrollmentsController < ApplicationController
	before_action :set_enrollment_group, only: [:edit_group, :delete_group, :document_deleted_logs, :delete_document]
	before_action :get_states, only: %i[client_search client_portal virtual_review_committee provider_source all_clients new_dco new_group data_access edit_group]
	before_action :get_provider_types, only: %i[client_search client_portal virtual_review_committee provider_source provider_enrollment new_group data_access edit_group]
	before_action :set_pagination_params, only: [:new_user, :edit_user]

	def index
		@enrollment_group = Group.all
	end

	# USER
	def new_user
		if request.post?
			@enrollment_user = User.new(user_params)
			@enrollment_user.from_source = 'enrollment'
			@enrollment_user.temporary_password = user_params[:password]
			@enrollment_user.temporary_password_confirmation = user_params[:password_confirmation]
			if @enrollment_user.save
				redirect_to new_user_enrollments_path, notice: "#{@enrollment_user.full_name} has been successfully created." and return
			end
		else
			@enrollment_user = User.new
		end

		@enrollment_users = if params[:user_search].present?
			User.where(from_source: 'enrollment').search(params[:user_search]).paginate(per_page: 10, page: params[:page] || 1)
		else
			User.where(from_source: 'enrollment').paginate(per_page: 10, page: params[:page] || 1)
		end
	end

	def edit_user
		@enrollment_user = User.find params[:id]
		if	request.patch?
			@enrollment_user.temporary_password = user_params[:password]
			@enrollment_user.temporary_password_confirmation = user_params[:password_confirmation]

			if @enrollment_user.update(user_params)
				redirect_to new_user_enrollments_path, notice: "#{@enrollment_user.full_name} has been successfully updated." and return
			end
		end
		@enrollment_users = User.where(from_source: 'enrollment').paginate(per_page: 10, page: params[:page] || 1)
		render 'new_user'
	end

	def delete_user
		user = User.find params[:id]
		if user.destroy
			redirect_to new_user_enrollments_path, notice: "#{user.full_name} has been deleted."
		else
				redirect_to new_user_enrollments_path, alert: 'Something went wrong'
		end
	end

	#GROUP
	def groups
		search_param = params[:group_search]
		if search_param.present?
				@enrollment_groups = EnrollmentGroup.where("group_name LIKE ? OR npi_digit_type LIKE ?", "%#{search_param}%", "%#{search_param}%")
		elsif current_user.can_access_all_groups? || current_user.super_administrator?
      @enrollment_groups = EnrollmentGroup.all
    else
      @enrollment_groups = current_user.enrollment_groups
    end
		render "enrollments/groups/index"
	end

	def new_group
		if request.post?
			@enrollment_group = EnrollmentGroup.new(group_params)
			# render json: params and return
			if @enrollment_group.save
				PlmMailer.with(
					email: Setting.take.t('system_notification_email'),
					subject: "Added Group",
					body: "#{current_user&.full_name} added a new group: #{@enrollment_group&.group_name}"
				).send_system_notification.deliver_later
				redirect_to groups_enrollments_path, notice: " Profile created for #{@enrollment_group.group_name} Group. Please complete all information." and return
			end
		else
			@enrollment_group = EnrollmentGroup.new
			@enrollment_group.contact_personnels.build
			@enrollment_group.details.build
			@enrollment_group.service_locations.build
			@enrollment_group.qualifacts_contacts.build if (current_setting.qualifacts? || current_setting.dcs?) && !@enrollment_group.qualifacts_contacts.present?
		end
	end

	def edit_group
		@view_only = params[:view_only] ||	false
		@enrollment_group = EnrollmentGroup.find params[:id]

		if @enrollment_group.details.blank?
			@enrollment_group.details.build
		end

		if @enrollment_group.contact_personnels.blank?
			@enrollment_group.contact_personnels.build
		end

		if @enrollment_group.service_locations.blank?
			@enrollment_group.service_locations.build
		end

		@enrollment_group.qualifacts_contacts.build if current_setting.qualifacts? && !@enrollment_group.qualifacts_contacts.present?

		if	request.patch?
			if @enrollment_group.update(group_params)
				PlmMailer.with(
					email: Setting.take.t('system_notification_email'),
					subject: "Edit Group",
					body: "#{current_user&.full_name} edited a group: #{@enrollment_group&.group_name}"
				).send_system_notification.deliver_later
				redirect_to groups_enrollments_path, notice: "#{@enrollment_group.group_name} has been successfully updated." and return
			end
		end
		render 'new_group'
	end

	def document_deleted_logs
		render json: {
			results:  @enrollment_group.deleted_document_logs.map {	|log| log.deleted_notes }
		}
	end

	def delete_document
		key = params[:key]
		note = params[:note]
		@enrollment_group.send("remove_#{key}!")
		if @enrollment_group.save!
			@enrollment_group.deleted_document_logs.create(
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

	def delete_group
		if @enrollment_group.destroy
			PlmMailer.with(
				email: Setting.take.t('system_notification_email'),
				subject: "Delete Group",
				body: "#{current_user&.full_name} deleted a group: #{@enrollment_group&.group_name}"
			).send_system_notification.deliver_later
			redirect_to groups_enrollments_path, notice: "#{@enrollment_group.group_name} has been deleted."
		else
			redirect_to groups_enrollments_path, alert: 'Something went wrong'
		end
	end

	protected

		def set_enrollment_group
			@enrollment_group = EnrollmentGroup.find(params[:id])
		end

		def get_states
			@states = State.all
		end

		def get_provider_types
			@provider_types = ProviderType.all
		end

		def user_params
			params.require(:user).permit(
				:first_name, :middle_name, :last_name, :suffix,
				:email, :password, :password_confirmation,
				:following_request, :user_type, :status, :user_role,
				:temporary_password, :temporary_password_confirmation, :title
			)
		end

		def group_params
			params.require(:enrollment_group).permit(
				 :group_note,
				 :new_group_notification,
				 :noti_group_start_date,
				 :noti_welcome_letter_sent,
				 :notification_enrollment_submit_group,
				 :noti_group_services,
				 :noti_status,
				 :noti_work_end_date,
				 :group_name,
				 :group_code,
				 :office_address,
				 :city,
				 :state,
				 :zip_code,
				 #to be deleted
				 :phone_number,
				 #to be deleted
				 :ext,
				 #to be deleted
				 :fax_number,
				 :billing_address_autofill,
				 :remittance_address_autofill,
				 :billing_contact_name,
				 :billing_contact_email,
				 :billing_contact_number,
				 :remmitance_contact_name,
				 :remmitance_contact_email,
				 :remmitance_contact_number,
				 :qualifacts_contract_effective_date,
				 :group_personnel_name,
				 :group_personnel_email,
				 :group_personnel_phone_number,
				 :group_personnel_fax_number,
				 :group_personnel_position,
				 :business_group,
				 :legal_business_name,
				 :another_business_name,
				 :other_business_name,
			   :other_business_type,
				 :specify_type_of_group,
				 :shared_tin,
				 :tin_file,
				 :specify_type_of_group_file,
				 :npi_digit_type,
			   :provider_type,
				 :po_box,
				 :po_box_city,
				 :po_box_state,
				 :po_box_zip_code,
				 :ca_po_box_address,
				 :ca_po_box_city,
				 :ca_po_box_state,
				 :ca_po_box_zip_code,
				 :individual_ownership,
					:tin_digit,
					:tin_digit_irs,
					:w9_file,
					:cp575_file,
					:specific_type_file,
					:ownership_file,
					:npi_digit_type_group,
					:payer_contracts,
					:group_type_documents,
					:eft_file,
					:roles,
					:voided_check_file,
					:flatform,
					:w9_signed_date,
					:w9_sign_date_expiration,
					:void_check_signed_date,
					:void_check_date_expiration,
					:bank_letter_signed_date,
					:bank_letter_date_expiration,
					:telehealth_providers,
					:admitting_privileges,
					:name_admitting_physician,
					:facility_location,
					:facility_name,
					:admitting_facility_address_line1,
					:admitting_facility_address_line2,
					:admitting_facility_city,
					:admitting_facility_state,
					:admitting_facility_zip_code,
					:admitting_facility_arrangments,
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
					:welcome_letter_status, :welcome_letter_subject, :welcome_letter_message, :check_welcome_letter, :check_co_caqh, :check_mn_caqh_state_release_form, :check_mn_caqh_authorization_form, :check_caqh_standard_authorization, {welcome_letter_attachments: []},
					contact_personnels_attributes: [:id, :group_personnel_name, :group_personnel_email, :group_personnel_phone_number, :group_personnel_fax_number, :group_personnel_position,
						:_destroy],
					details_attributes: [:id, :individual_ownership_first_name, :individual_ownership_middle_name, :email_address, :individual_ownership_last_name,:individual_ownership_title, :individual_ownership_ssn, :individual_ownership_dob, :individual_ownership_percent_of_ownership, :individual_ownership_effective_date, :individual_ownership_control_date, :group_role,
					:_destroy],
					service_locations_attributes: [:id, :primary_service_non_office_area, :primary_service_location_apps, :primary_service_zip_code, :primary_service_office_email, :primary_service_fax, :primary_service_office_website, :primary_service_crisis_phone, :primary_service_location_other_phone, :primary_service_appt_scheduling, :primary_service_interpreter_language, :primary_service_telehealth_only_state],
					qualifacts_contacts_attributes: [:id, :department, :name, :role, :email, :phone, :_destroy]
			)
		end

		def set_pagination_params
			@per_page = params[:per_page] || 100
			@page = params[:page] || 1
		end
end
class EnrollGroupsController < ApplicationController
	before_action :set_enroll_group, only: [:edit, :update, :destroy, :show]
 before_action :set_enroll_groups, only: [:index, :show]
	before_action :set_enrollment_groups, only: [:new, :edit, :update]

	def index
	end

	def new
		@enroll_group = EnrollGroup.new
		details = @enroll_group.details.build
		details.questions.build
	end

	def edit
   if @enroll_group.details.blank?
     details = @enroll_group.details.build
     details.questions.build
   end
 end

	def create
		@enroll_group = EnrollGroup.new(enroll_group_params)
		if @enroll_group.save(validate: false)
			@enroll_group.update_columns(
				payer: params[:payer]
			)
			redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
			redirect_to redirect_url, notice: 'Enrollment Group has been successfully created.'
		else
			render 'new'
		end
	end

	def update
		@enroll_group.assign_attributes(enroll_group_params)
		@enroll_group.remove_upload_payor_files! # remove upload payor files if not present, for handling all files deletion

		if @enroll_group.save(validate: false)
			@enroll_group.update_columns(payer: params[:payer])
			redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
			redirect_to redirect_url, notice: 'Enrollment Group has been successfully updated.'
		else
			render 'edit'
		end
	end

	def destroy
		redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enroll_groups_path
		if @enroll_group.destroy
			redirect_to redirect_url, notice: 'Enrollment Group has been successfully deleted.'
		else
			redirect_to redirect_url, alert: 'Something went wrong'
		end
	end

  def show
    @comment = EnrollmentComment.new
    @comment.enroll_group = @enroll_group
    @comment.user_id = current_user.id
  end

	protected

	def set_enrollment_groups
		if action_name == "new" || (action_name == "edit" && !@enroll_group&.group_id.present?)
			@enrollment_groups = EnrollmentGroup.includes(:enroll_group).where(enroll_group: { id: nil })
		elsif action_name == "edit"
			@enrollment_groups = EnrollmentGroup.where("NOT EXISTS (SELECT 1 FROM enroll_groups WHERE enroll_groups.group_id = enrollment_groups.id AND enrollment_groups.id <> #{@enroll_group&.group_id || 0})")
		else
			@enrollment_groups = EnrollmentGroup.all
		end
		if !current_user.can_access_all_groups? && !current_user&.super_administrator?
			@enrollment_groups = @enrollment_groups.where(id: current_user.enrollment_groups.pluck(:id))
		end
	rescue
		@enrollment_groups = EnrollmentGroup.all
	end

	def set_enroll_group
		@enroll_group = EnrollGroup.find(params[:id])
	end

	def enroll_group_params
		params.require(:enroll_group).permit(
					:name,
					:first_name,
					:middle_name,
					:last_name,
					:suffix,
					:email,
					:telephone_number,
					:medicare_ptan,
					:medicaid_group_number,
					:bcbs_number,
					:tricate_military,
					:commercial_name,
	 				:contracted,
					:revalidated,
					:revalidated_payer_name,
					:application_contracts,
					:application_payer_name,
					:with_medicare,
					:with_eft,
					:voided_bank_letter,
					:with_edi,
					:payer,
					:status,
					:group_id,
					:user_id,
					:outreach_type,
					:dco,
					details_attributes: [
						:id, :payer_state, :group_number, :enrollment_payer, :payer, :effective_date, :revalidation_date,
						:application_status, :payor_type, :medicare_tricare, :payor_name,
						:payor_phone, :payor_submission_type, :payor_email, :payor_link, :payor_username, :password,
						:payor_question, :payor_answer, :portal_admin, :enrollment_link, :portal_username, :portal_password,  :portal_admin_email, :portal_admin_name, :caqh_payer, :eft, :era, :client_notes, :notes, :_destroy, {upload_payor_file: []},
						questions_attributes: [:id, :secret_question, :answer, :_destroy]
					],
	)
	end

  def set_enroll_groups
    @enroll_groups = if params[:enroll_group_search].present?
      EnrollGroup.search(params[:enroll_group_search]).paginate(per_page: 10, page: params[:page] || 1)
    else
      EnrollGroup.all.paginate(per_page: 10, page: params[:page] || 1)
    end
  end
end


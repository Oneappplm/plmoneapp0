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
    # had to add this condition to prvent details fields from duplicating
				# render json: @enroll_group.details.map{|d| d if d.id.blank?} and return
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
    @comment.user = current_user
  end

	protected

	def set_enrollment_groups
		if action_name == "new"
			@enrollment_groups = EnrollmentGroup.includes(:enroll_group).where(enroll_group: { id: nil })
		elsif action_name == "edit"
			@enrollment_groups = EnrollmentGroup.where("NOT EXISTS (SELECT 1 FROM enroll_groups WHERE enroll_groups.group_id = enrollment_groups.id AND enrollment_groups.id <> #{@enroll_group&.group_id || 0})")
		else
			@enrollment_groups = EnrollmentGroup.all
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
						:payor_question, :payor_answer, :portal_admin, :enrollment_link, :portal_username, :portal_password,  :portal_admin_email, :portal_admin_name, :caqh_payer, :eft, :era, :client_notes, :notes, :upload_payor_file, :_destroy,
						questions_attributes: [:id, :secret_question, :answer]
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


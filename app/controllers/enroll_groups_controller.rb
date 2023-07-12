class EnrollGroupsController < ApplicationController
	before_action :set_enroll_group, only: [:edit, :update, :destroy, :show]
  before_action :set_enroll_groups, only: [:index, :show]
	def index
	end

	def new
		@enroll_group = EnrollGroup.new
    details = @enroll_group.details.build
    details.questions.build
	end

	def edit
    # had to add this condition to prvent details fields from duplicating
    if @enroll_group.details.blank?
     details = @enroll_group.details.build
     details.questions.build
   end
  end

	def create
		@enroll_group = EnrollGroup.new(enroll_group_params)
		if @enroll_group.save
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
		if @enroll_group.update(enroll_group_params)
			#binding.break
			@enroll_group.update_columns(
				payer: params[:payer]
			)
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
          # details_attributes: [:id, :start_date, :due_date, :enrollment_payer, :enrollment_type, :enrollment_status, :approved_date, :revalidation_date, :revalidation_due_date, :comment, :ptan_number ,:_destroy],
          details_attributes: [ :id, :state_id, :group_number, :enrollment_payer, :payer, :effective_date, :revalidation_date,
                      :application_status, :payor_type, :medicare_tricare, :payor_name,
                      :payor_phone, :payor_email, :enrollment_link, :payor_username, :payor_password,
                      :payor_question, :payor_answer, :portal_admin, :portal_admin_name,
                      :portal_admin_phone, :portal_admin_email, :caqh_payer, :eft, :era, :client_notes, :notes, :_destroy,
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


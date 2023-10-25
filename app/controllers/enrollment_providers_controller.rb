class EnrollmentProvidersController < ApplicationController
	before_action :set_enrollment_provider, only: [:edit, :update, :destroy, :show]
  before_action :set_enrollment_providers, only: [:index, :show]

  def index;end

	def new
		@enrollment_provider = EnrollmentProvider.new(outreach_type: 'provider-from-enrollment')
		@enrollment_provider.details.build.questions.build
	end

	def edit
		@enrollment_provider.outreach_type = 'provider-from-enrollment' if @enrollment_provider.outreach_type.blank?

		# had to add this condition to prvent details fields from duplicating
		if @enrollment_provider.details.blank?
				@enrollment_provider.details.build
		end
 end

	def create
		@enrollment_provider = EnrollmentProvider.new(enrollment_provider_params)
		@enrollment_provider.enrolled_by = current_user&.full_name
		if @enrollment_provider.save
			@enrollment_provider.update_columns(
				provider_id: params[:provider_id],
				outreach_type:	params[:outreach_type]
			)
			redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
			redirect_to redirect_url, notice: 'Enrollment Provider has been successfully created.'
		else
			render 'new'
		end
	end

	def update

		@enrollment_provider.assign_attributes(enrollment_provider_params)
		@enrollment_provider.remove_upload_payor_files! # remove upload payor files if not present, for handling all files deletion

		if @enrollment_provider.save(validate: false)
			@enrollment_provider.update_columns(
				provider_id: params[:provider_id],
				outreach_type:	params[:outreach_type]
			)
			redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
			redirect_to redirect_url, notice: 'Enrollment Provider has been successfully updated.'
		else
			render 'edit'
		end
	end

	def destroy
		redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
		if @enrollment_provider.destroy
			redirect_to redirect_url, notice: 'Enrollment Provider has been successfully deleted.'
		else
			redirect_to redirect_url, alert: 'Something went wrong'
		end
	end

  def show
    @comment = EnrollmentComment.new
    @comment.enrollment_provider = @enrollment_provider
    @comment.user = current_user
  end

	protected
	def set_enrollment_provider
		@enrollment_provider = EnrollmentProvider.find(params[:id])
	end

	def enrollment_provider_params
		params.require(:enrollment_provider).permit(
			:name,
			:state_license_submitted,
			:state_license_file,
			:dea_submitted,
			:dea_file,
			:irs_letter_submitted,
			:irs_letter_file,
			:w9_submitted,
			:w9_file,
			:voided_check_submitted,
			:voided_check_file,
			:curriculum_vitae_submitted,
			:curriculum_vitae_file,
			:cms_460_submitted,
			:cms_460_file,
			:eft_submitted,
			:eft_file,
			:cert_insurance_submitted,
			:cert_insurance_file,
			:driver_license_submitted,
			:driver_license_file,
			:board_certification_submitted,
			:board_certification_file,
			:status,
			:application_id,
			:not_submitted_note,
			:not_submitted_note_rejected,
			:approved_date,
			:approved_confirmation,
			:provider_id,
			:user_id,
			:outreach_type,
			:first_name,
			:middle_name,
			:last_name,
			:suffix,
			:telephone_number,
			:email_address,
      details_attributes: [:id, :due_date,
                           :enrollment_payer, :enrollment_type, :enrollment_status, :payer_state,
                           :approved_date, :revalidation_date, :revalidation_due_date, :denied_date,
                           :comment, :ptan_number, :provider_ptan, :group_ptan,
                           :enrollment_tracking_id, :enrollment_effective_date,
                           :association_start_date, :business_end_date, :association_end_date,
                           :line_of_business, :revalidation_status, :cpt_code, :descriptor,
                           :provider_id, :group_id, :upload_payor_file, :processing_date, :terminated_date, :payor_username, :payor_password, :_destroy, {upload_payor_file: []}, questions_attributes: [:id, :question, :answer] ],

		)
	end

  def set_enrollment_providers
    @enrollment_providers = if params[:enrollment_provider_search].present?
      EnrollmentProvider.search(params[:enrollment_provider_search]).paginate(per_page: 10, page: params[:page] || 1)
    else
      EnrollmentProvider.all.paginate(per_page: 10, page: params[:page] || 1)
    end
  end
end

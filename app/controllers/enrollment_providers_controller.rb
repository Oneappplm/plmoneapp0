class EnrollmentProvidersController < ApplicationController
	before_action :set_enrollment_provider, only: [:edit, :update, :destroy, :show]
  before_action :set_enrollment_providers, only: [:index, :show]

  def index;end

	def new
		@enrollment_provider = EnrollmentProvider.new
    @enrollment_provider.details.build
	end

	def edit
    @enrollment_provider.details.build
  end

	def create
		@enrollment_provider = EnrollmentProvider.new(enrollment_provider_params)
		@enrollment_provider.enrolled_by = current_user.full_name
		if @enrollment_provider.save
			redirect_to enrollment_providers_path, notice: 'Enrollment Provider has been successfully created.'
		else
			render 'new'
		end
	end

	def update
		if @enrollment_provider.update(enrollment_provider_params)
			redirect_to enrollment_providers_path, notice: 'Enrollment Provider has been successfully updated.'
		else
			render 'edit'
		end
	end

	def destroy
		if @enrollment_provider.destroy
			redirect_to enrollment_providers_path, notice: 'Enrollment Provider has been successfully deleted.'
		else
			redirect_to enrollment_providers_path, alert: 'Something went wrong'
		end
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
      details_attributes: [:id, :start_date, :due_date, :enrollment_payer, :enrollment_type, :enrollment_status, :approved_date, :revalidation_date, :revalidation_due_date, :comment, :ptan_number ,:_destroy],

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

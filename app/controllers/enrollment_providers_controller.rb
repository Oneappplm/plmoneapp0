require 'zip'
require 'open-uri'
class EnrollmentProvidersController < ApplicationController
	include ActionController::Live  # Enables live streaming
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
				outreach_type:	params[:outreach_type],
				updated_by: current_user&.full_name
			)
			redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
			redirect_to redirect_url, notice: "Enrollment #{@enrollment_provider.full_name} has been successfully created."
		else
			render 'new'
		end
	end

	def update
		detail_params = enrollment_provider_params[:details_attributes].values.first
	  detail = @enrollment_provider.details.find(detail_params[:id])

	   # Capture the old status before changes
	  old_status = detail.enrollment_status

	  # Assign the new attributes to the provider
  	@enrollment_provider.assign_attributes(enrollment_provider_params)

		@enrollment_provider.remove_upload_payor_files! # remove upload payor files if not present, for handling all files deletion

		if @enrollment_provider.save(validate: false)

			new_status = detail_params[:enrollment_status]

			 # Send the email if the status has changed
	    if old_status != new_status
	      provider_name = @enrollment_provider.full_name
	      payer = detail.enrollment_payer

	      EnrollmentProviderMailer.status_changed(provider_name, payer, old_status, new_status, current_user.email).deliver_later
	    end

			@enrollment_provider.update_columns(
				provider_id: params[:provider_id],
				outreach_type:	params[:outreach_type],
				updated_by: current_user&.full_name
			)
			redirect_url = current_setting.qualifacts? ? client_provider_enrollments_path : enrollment_providers_path
			redirect_to redirect_url, notice: "Enrollment #{@enrollment_provider.full_name} has been successfully updated."
		else
			render 'edit'
		end
	end

	def download_all_pdfs
    pdf_urls = params[:pdf_urls] || []
    
    if pdf_urls.blank?
      render plain: "No PDF URLs provided", status: :unprocessable_entity
      return
    end
    
    Rails.logger.info "Attempting to download PDFs: #{pdf_urls.inspect}"
    
    # Create a temporary ZIP file
    temp_file = Tempfile.new(['all_pdfs', '.zip'])
    
    begin
      # Download and package PDFs in ZIP
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        pdf_urls.each_with_index do |url, index|
          Rails.logger.info "Downloading PDF from #{url}"
          pdf_data = URI.open(url, open_timeout: 10, read_timeout: 10, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
          if pdf_data.present?
            zipfile.get_output_stream("file_#{index + 1}.pdf") { |f| f.write(pdf_data) }
          else
            Rails.logger.error "Downloaded PDF from #{url} was empty"
          end
        end
      end

      # Check if the ZIP file is valid and non-empty
      if File.size(temp_file.path) > 0
        response.headers['Content-Type'] = 'application/zip'
        response.headers['Content-Disposition'] = 'attachment; filename="all_pdfs.zip"'
        response.headers['Content-Length'] = File.size(temp_file.path).to_s
        
        # Stream the file
        File.open(temp_file.path, 'rb') do |file|
          response.stream.write(file.read)
        end
      else
        render plain: "Failed to create ZIP file", status: :unprocessable_entity
      end
      
    rescue => e
      Rails.logger.error "Error creating or sending ZIP file: #{e.message}"
      render plain: "Error occurred during ZIP creation or download", status: :internal_server_error
    ensure
      temp_file.close
      temp_file.unlink  # Deletes the file
      response.stream.close  # Ensure to close the stream
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
    @comment.user_id = current_user.id
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
      details_attributes: [:id, :start_date, :due_date,
                           :enrollment_payer, :enrollment_type, :enrollment_status, :payer_state,
                           :approved_date, :revalidation_date, :revalidation_due_date, :denied_date,
                           :comment, :ptan_number, :provider_ptan, :group_ptan,
                           :enrollment_tracking_id, :enrollment_effective_date,
                           :association_start_date, :business_end_date, :association_end_date,
                           :line_of_business, :revalidation_status, :cpt_code, :descriptor,
                           :provider_id, :tax_id, :location, :group_id, :upload_payor_file, :processing_date, :terminated_date, :payor_email, :payor_phone, :payor_username, :payor_password, :_destroy, {upload_payor_file: []}, questions_attributes: [:id, :question, :answer, :_destroy] ],

		)
	end

  def set_enrollment_providers
    if params[:enrollment_provider_search].present?
      search_term = "%#{params[:enrollment_provider_search]}%"
      @enrollment_providers = EnrollmentProvider.joins(:provider)
        .where("CONCAT(providers.first_name, ' ', providers.middle_name, ' ', providers.last_name) ILIKE ?", search_term)
        .paginate(per_page: 10, page: params[:page] || 1)
    else
      @enrollment_providers = EnrollmentProvider.includes(:provider).paginate(per_page: 10, page: params[:page] || 1)
    end
  end
end

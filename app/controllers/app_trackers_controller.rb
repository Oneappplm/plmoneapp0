class AppTrackersController < ProvidersController
	before_action :set_providers, only: [:index]
	before_action :set_provider, only: [:upload_documents, :delete_uploaded_document, :view_uploaded_documents]

	def index
	  @provider_personal_information = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
	  @provider_personal_attempt = ProviderPersonalAttempt.new
	  @provider_personal_docs_receive = ProviderPersonalDocsReceive.new
	  @practice_information = PracticeInformation.new
	  @practice_information = PracticeInformation.paginate(per_page: 10, page: params[:page] || 1)
	  @client_organizations = ClientOrganization.paginate(per_page: 10, page: params[:page] || 1)

	  # Filtering for @app_trackers
	  if params[:user_search].present?
		  search_term = "%#{params[:user_search]}%"
		  @provider_personal_information = @provider_personal_information.where(
		    "first_name ILIKE ? OR middle_name ILIKE ? OR last_name ILIKE ? OR caqh_provider_attest_id::text ILIKE ?",
		    search_term, search_term, search_term, search_term
		  )
		end

	  if params[:app_reviewed].present?
		  bool_value = ActiveModel::Type::Boolean.new.cast(params[:app_reviewed]) # Convert "true"/"false" string to boolean
		  @practice_information = @practice_information.where(app_reviewed: bool_value)

		  if bool_value == false || @practice_information.empty? && @provider_personal_information.exists?
		    flash[:alert] = "No results found"
		  end
		end

	  @practice_information = @practice_information.where(provider_status: params[:provider_status]) if params[:provider_status].present?
	  @practice_information = @practice_information.where(file_due_date: params[:file_due_date]) if params[:file_due_date].present?
	  @practice_information = @practice_information.where(cred_cycle: params[:cred_cycle]) if params[:cred_cycle].present?
	  @practice_information = @practice_information.where(batch_description: params[:batch_description]) if params[:batch_description].present?

		@client_organizations = @client_organizations.where(organization_name: params[:organization_name]) if params[:organization_name].present?	  

	  if @practice_information.exists? && @client_organizations.exists? && @provider_personal_information.exists?
		  # Results found
		else
		  flash[:alert] = "No results found"
		end
	end

	# for uploading the documents
	def provider_personal_docs_uploaded_documents
		caqh_provider_attest_id = params[:provider_personal_docs_upload][:caqh_provider_attest_id]

		@documents = ProviderPersonalDocsUpload.where(caqh_provider_attest_id: params[:provider_personal_docs_upload][:caqh_provider_attest_id])
		@document = ProviderPersonalDocsUpload.new

		if request.post?
			@document = ProviderPersonalDocsUpload.new(provider_personal_docs_upload_params)
			if @document.save
				redirect_to app_trackers_path, notice: 'Document uploaded successfully.'
			end
		end
	end


	# for provider_personal_attempt 
	def save_attempt_details
	  @provider_personal_attempt = ProviderPersonalAttempt.new(attempt_params)

	  provider_personal_info = ProviderPersonalInformation.find_by(caqh_provider_id: @provider_personal_attempt.caqh_provider_id)

	  if provider_personal_info
	    @provider_personal_attempt.provider_personal_information_id = provider_personal_info.id
	  else
	    flash[:alert] = "No provider personal information found for the given CAQH Provider ID."
	    redirect_to app_trackers_path and return
	  end

	  if @provider_personal_attempt.save
	    redirect_to app_trackers_path, notice: "Provider Personal Attempt created successfully."
	  else
	    flash[:alert] = @provider_personal_attempt.errors.full_messages.join(", ")
	    redirect_to app_trackers_path
	  end
	end


	def save_provider_personal_docs_receives
	  # Find the provider personal information based on the given ID
	  provider_info = ProviderPersonalInformation.find(params[:provider_personal_docs_receive][:provider_personal_information_id])

	  # Attempt to find the associated ProviderPersonalDocsReceive record
	  @provider_personal_docs_receive = provider_info.provider_personal_docs_receive

	  # If no record is found, build a new one
	  if @provider_personal_docs_receive.nil?
	    @provider_personal_docs_receive = provider_info.build_provider_personal_docs_receive
	  end

	  # Update the record (either found or newly built)
	  if @provider_personal_docs_receive.update(provider_personal_docs_receive_params)
	    # If update was successful, notify user that the record was updated or created
	    notice_message = @provider_personal_docs_receive.persisted? ? 'updated' : 'created'
	    redirect_to app_trackers_path, notice: "Provider Personal Docs Receives #{notice_message} successfully."
	  else
	    # If save failed, notify user and show the appropriate form
	    flash[:alert] = "Failed to save Provider Personal Docs Receives."
	    render @provider_personal_docs_receive.new_record? ? :new : :edit
	  end
	end

	# # for provider_practice_informations in this update & create both methods are present
	def save_provider_practice_informations
		provider_attest_id = params[:practice_information][:provider_attest_id]
	  practice_info_id = params[:practice_information][:id]

	  if practice_info_id.present?
	    @practice_information = PracticeInformation.find_by(id: practice_info_id)
	  else
	    @practice_information = PracticeInformation.find_by(provider_attest_id: provider_attest_id)
	  end

	  if @practice_information.present?
	    if @practice_information.update(practice_information_params)
	      redirect_to app_trackers_path, notice: 'Practice Information updated successfully.'
	    else
	      flash[:alert] = "Failed to update Practice Information."
	      render :edit
	    end
	  else
	    @practice_information = PracticeInformation.new(practice_information_params)
	    if @practice_information.save
	      redirect_to app_trackers_path, notice: 'Practice Information created successfully.'
	    else
	      flash[:alert] = "Failed to create Practice Information."
	      render :new
	    end
	  end
	end

	protected

	def provider_personal_docs_upload_params
		params.require(:provider_personal_docs_upload).permit(
			:file_upload,
			:provider_id,
			:provider_attest_id,
			:provider_personal_information_id,
			:caqh_provider_attest_id,
			:caqh_provider_id
		)
	end

	def attempt_params
		params.require(:provider_personal_attempt).permit(
			:provider_attest_id,
			:contact_method,
			:attempt_status,
			:contact_date,
			:comments,
			:caqh_provider_id,
			:caqh_provider_attest_id,
			:provider_personal_information_id
		)
	end

	def provider_personal_docs_receive_params
		params.require(:provider_personal_docs_receive).permit(
			:provider_id,
	    :provider_attest_id,
	    :application_received_date,
			:release_received_date,
			:disclosure_questions_explanation_received_date,
			:face_sheet_received_date,
			:employment_gap_received_date,
			:practice_information_received_date,
			:npdb_findings_explanation_received_date,
			:training_received_date,
			:education_received_date,
			:professional_resource_network_received_date,
			:dea_received_date,
			:pa_sponsor_request_form_received_date,
			:collaborative_agreement_received_date,
			:application_received_flag,
			:release_received_flag,
			:disclosure_questions_explanation_received_flag,
			:face_sheet_received_flag,
			:employment_gap_received_flag,
			:practice_information_received_flag,
			:npdb_findings_explanation_received_flag,
			:training_received_flag,
			:education_received_flag,
			:professional_resource_network_received_flag,
			:dea_received_flag,
			:pa_sponsor_request_form_received_flag,
			:collaborative_agreement_received_flag,
			:application_received_incomplete_flag,
			:release_received_incomplete_flag,
			:disclosure_questions_explanation_received_incomplete_flag,
			:face_sheet_received_incomplete_flag,
			:employment_gap_received_incomplete_flag,
			:practice_information_received_incomplete_flag,
			:npdb_findings_explanation_received_incomplete_flag,
			:training_received_incomplete_flag,
			:education_received_incomplete_flag,
			:professional_resource_network_received_incomplete_flag,
			:dea_received_incomplete_flag,
			:pa_sponsor_request_form_received_incomplete_flag,
			:collaborative_agreement_received_incomplete_flag,
			:application_comments,
			:release_comments,
			:disclosure_questions_explanation_comments,
			:face_sheet_comments,
			:employment_gap_comments,
			:practice_information_comments,
			:npdb_findings_explanation_comments,
			:training_comments,
			:education_comments,
			:professional_resource_network_comments,
			:dea_comments,
			:pa_sponsor_request_form_comments,
			:collaborative_agreement_comments,
			:caqh_provider_id, 
			:caqh_provider_attest_id,
			:provider_personal_information_id
	   )
	end

	def practice_information_params
		params.require(:practice_information).permit(
			:id,
			:address,
			:address2,
			:city,
			:state,
			:fax_number,
			:phone_number,
			:email_address,
			:provider_type,
			:cred_cycle,
			:npi,
			:ssn,
			:caqh_provider_practice_id,
			:caqh_provider_attest_id,
			:birth_date,
			:provider_status,
			:attestation_date,
			:file_due_date,
			:app_complete_date,
			:app_reviewed,
			:batch_description,
			:comment,
			:provider_attest_id
		)
	end

	def set_providers
		if params[:user_search].present?
			search_term = params[:user_search].strip.downcase
			@providers = Provider.unscoped.where("
				LOWER(first_name) LIKE :search OR
				LOWER(last_name) LIKE :search OR
				LOWER(middle_name) LIKE :search OR
				LOWER(npi) LIKE :search OR
				CONCAT(LOWER(first_name), ' ', LOWER(last_name)) LIKE :search OR
				CONCAT(LOWER(first_name), ' ', LOWER(middle_name), ' ', LOWER(last_name)) LIKE :search
			", search: "%#{search_term}%")
		else
			@providers = Provider.unscoped
		end
	end

	def set_provider
		@provider = Provider.find_by_id params.dig(:id)
	end
end

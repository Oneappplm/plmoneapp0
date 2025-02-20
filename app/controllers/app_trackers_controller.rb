class AppTrackersController < ProvidersController
	before_action :set_providers, only: [:index]
	before_action :set_provider, only: [:upload_documents, :delete_uploaded_document, :view_uploaded_documents]

	def index
	  @provider_personal_information = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
	  @clients = Client.paginate(per_page: 10, page: params[:page] || 1)
	  @provider_personal_attempt = ProviderPersonalAttempt.new
	  @provider_personal_docs_receive = ProviderPersonalDocsReceive.new
	  @practice_information = PracticeInformation.new
	  @client_organizations = ClientOrganization.all
	end

	# for uploading the documents
	def provider_personal_docs_uploaded_documents
		provider_id = params[:provider_personal_docs_upload][:provider_id]

		@documents = ProviderPersonalDocsUpload.where(provider_id: params[:provider_id])
		@document = ProviderPersonalDocsUpload.new

		if request.post?
			@document = ProviderPersonalDocsUpload.new(provider_personal_docs_upload_params)
			if @document.save
				redirect_to app_trackers_path, notice: 'Document uploaded successfully.'
			end
		end
	end


	# def upload_documents
	# 	@document = @provider.uploaded_documents.new
	# 	if request.post?
	# 		@document = @provider.uploaded_documents.new(document_params)
	# 		if @document.save
	# 			redirect_to app_trackers_path, notice: 'Document uploaded successfully.'
	# 		end
	# 	end
	# end

	# def delete_uploaded_document
	# 	doc_id = params.dig(:doc_id)
	# 	doc_file = @provider.uploaded_documents.find_by_id(doc_id)
	# 	if doc_file.destroy
	# 		redirect_to request.referrer, notice: "Successfully deleted."
	# 	else
	# 		redirect_to request.referrer, alert: "Something went wrong."
	# 	end
	# end

	# def view_uploaded_documents; end

	# for provider_personal_attempt 
	def save_attempt_details
		@provider_personal_attempt = ProviderPersonalAttempt.new(attempt_params)
		if @provider_personal_attempt.save
			redirect_to app_trackers_path, notice: "Provider Personal Attempt created successfully."
		end
	end

	# for provider_personal_docs_receives in this update & create both methods are present
	def save_provider_personal_docs_receives
	  provider_id, provider_attest_id = params[:doc_recived_id].split(" ")

	  @provider_personal_docs_receive = ProviderPersonalDocsReceive.find_by(provider_id: provider_id, provider_attest_id: provider_attest_id)
    
	  if @provider_personal_docs_receive.present?
	    if @provider_personal_docs_receive.update(provider_personal_docs_receive_params)
	      redirect_to app_trackers_path, notice: "Provider Personal Docs Receives updated successfully."
	    else
	      render :edit, alert: "Failed to update Provider Personal Docs Receives."
	    end
	  else
	    @provider_personal_docs_receive = ProviderPersonalDocsReceive.new(provider_personal_docs_receive_params)
	    if @provider_personal_docs_receive.save
	      redirect_to app_trackers_path, notice: "Provider Personal Docs Receives created successfully."
	    else
	      render :new, alert: "Failed to create Provider Personal Docs Receives."
	    end
	  end
	end
	
	# # for provider_practice_informations in this update & create both methods are present
	def save_provider_practice_informations
		provider_attest_id = params[:practice_information][:provider_attest_id]
	  practice_info_id = params[:practice_information][:id] # Fetch practice_information ID

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
			:provider_attest_id
		)
	end


	# def document_params
	# 	params.require(:provider_uploaded_document).permit(
	# 		:image_classification,
	# 		:sub_section,
	# 		:description,
	# 		:exclude_from_profile,
	# 		:file_upload
	# 	)
	# end

	def attempt_params
		params.require(:provider_personal_attempt).permit(
			:provider_id,
			:provider_attest_id,
			:contact_method,
			:attempt_status,
			:contact_date,
			:comments
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
			:collaborative_agreement_comments
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

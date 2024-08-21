class AppTrackersController < ProvidersController
	before_action :set_providers, only: [:index]
	before_action :set_provider, only: [:upload_documents, :delete_uploaded_document, :view_uploaded_documents]

	def index
	  @providers = Provider.paginate(per_page: 10, page: params[:page] || 1)
	  @clients = Client.paginate(per_page: 10, page: params[:page] || 1)
	  @app_trackers = AppTracker.all

	  # Filtering for @clients
	  @clients = @clients.where(client_name: params[:client_name]) if params[:client_name].present?

	  # Filtering for @app_trackers
	  @providers = @providers.where(id: params[:user_search]) if params[:user_search].present?
	  @providers = @providers.where(cred_cycle: params[:cred_cycle]) if params[:cred_cycle].present?
	  @providers = @providers.where(provider_status: params[:provider_status]) if params[:provider_status].present?
	  @providers = @providers.where(application_reviewed: params[:application_reviewed]) if params[:application_reviewed].present?
	  @providers = @providers.where(batch_description: params[:batch_description]) if params[:batch_description].present?
	  @providers = @providers.where(file_due_date: params[:file_due_date]) if params[:file_due_date].present?

	  # Paginate after filtering
	  @clients = @clients.paginate(per_page: 10, page: params[:page] || 1)
	  @providers = @providers.paginate(per_page: 10, page: params[:page] || 1)

	  # Check if there are no results
    if @providers.empty? && @clients.empty?
      flash.now[:alert] = "No results found for your search criteria."
    end

	end


	def upload_documents
		@document = @provider.uploaded_documents.new
		if request.post?
			@document = @provider.uploaded_documents.new(document_params)
			if @document.save
				redirect_to app_trackers_path, notice: 'Document uploaded successfully.'
			end
		end
	end

	def delete_uploaded_document
		doc_id = params.dig(:doc_id)
		doc_file = @provider.uploaded_documents.find_by_id(doc_id)
		if doc_file.destroy
			redirect_to request.referrer, notice: "Successfully deleted."
		else
			redirect_to request.referrer, alert: "Something went wrong."
		end
	end

	def view_uploaded_documents; end

	protected
	def document_params
		params.require(:provider_uploaded_document).permit(
			:image_classification,
			:sub_section,
			:description,
			:exclude_from_profile,
			:file_upload
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

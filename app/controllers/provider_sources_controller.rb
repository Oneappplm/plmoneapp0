class ProviderSourcesController < ApplicationController
	before_action :set_current_provider_source_and_redirect_to_edit_page, only: [:edit]
	before_action :create_provider_source_and_redirect_to_edit_page, only: [:new]

	def new
  end

  def edit; end

	def destroy
		@provider_source = ProviderSource.find(params[:id])
		@provider_source.destroy
		redirect_to provider_sources_path, notice: "Provider Source was successfully destroyed."
	end

	def index
		if params[:search].present?
      search_term = "%#{params[:search]}%"
      
      # Use LEFT JOIN to ensure all provider sources are included
      @provider_sources = ProviderSource
        .left_joins(:data)
        .where("provider_source_data.data_key IN ('first_name', 'last_name') AND provider_source_data.data_value LIKE ?", search_term).where(created_by_user: current_user.id)
        .distinct # Ensure uniqueness
    else
			@provider_sources = ProviderSource.where(created_by_user: current_user.id)
			@provider_source = ProviderSource.new
		end
	end

	def autosave
		return unless params[:field_name].present? && params[:value].present?

		field_name = params[:field_name].parameterize(separator: '_')
		value = params[:value]

		data = current_provider_source.data.find_or_create_by(data_key: field_name)
	  data.update_columns data_value: value.is_a?(Array) ? value.join(",") : value

		respond_to do |format|
				format.json { render json: { success: true, data_key: field_name, data_value: value } }
		end
	end
  
  # upload provider source documents
	def upload_document
	  provider_source_id = params[:provider_source_id]
	  uploaded_file = params[:file]

	  if uploaded_file.present?
	    file_name = uploaded_file.original_filename

	    provider_source_document = ProviderSourceDocument.new(
	      provider_source_id: provider_source_id,
	      file_name: file_name
	    )

	    provider_source_document.file_path = uploaded_file

	    if provider_source_document.save
        redirect_to custom_provider_source_path(page: 'manage_document')
	    end
	  end
	end

  def get_progress
    data_group = params[:data_group]
    @provider = ProviderSource.current_provider_source_by_current_user(current_user.id)

    progress = @provider.send(data_group)

    respond_to do |format|
      format.json  { render json: { progress: progress } }
    end
  end

  def autosave_multi_record
    model = params[:model]
    id = params[:id]
    content = params[:content]
    field = params[:field]

    record = if model == 'dea'
      ProviderSourcesDea.find(id)
    elsif model == 'cds'
      ProviderSourcesCds.find(id)
    elsif model == 'registration'
      ProviderSourcesRegistration.find(id)
    elsif model == 'cme'
      ProviderSourceCme.find(id)
    end

    record.update_attribute(field,content)
  end

	def fetch
		return unless params[:field_name].present?

		field_name = params[:field_name].parameterize(separator: '_')
		data = current_provider_source.data.find_or_create_by(data_key: field_name)

		respond_to do |format|
				format.json { render json: { value: filtered_value(data&.data_value, field_name) } }
		end
	end

	def filtered_value field_value, field_name
		case field_name
		when 'ps-dob'
			field_value.present? ? Date.parse(field_value).strftime('%Y-%m-%d') : ''
		else
			field_value
		end
	end

	def download_documents 
    document_ids = params[:document_ids]
    documents = ProviderSourceDocument.where(id: document_ids)

    if documents.any?
      # Assuming only one document can be downloaded at a time for simplicity
      document = documents.first
      file_url = document.file_path.url

      if remote_file_exists?(file_url)
        redirect_to file_url, allow_other_host: true
      else
        redirect_back fallback_location: custom_provider_source_path(page: 'manage_document'), alert: 'Selected document could not be found for download.'
      end
    else
      redirect_back fallback_location: custom_provider_source_path(page: 'manage_document'), alert: 'No documents found for download.'
    end
  end

  def edit_document
   document = ProviderSourceDocument.find(params[:document_id])
	  uploaded_file = params[:document_file]

	  if document.present? && uploaded_file.present?
	    document.file_path = uploaded_file
	    document.file_name = uploaded_file.original_filename

	    if document.save
	      redirect_to custom_provider_source_path(page: 'manage_document'), notice: 'Document was successfully updated.'
	    else
	      redirect_to custom_provider_source_path(page: 'manage_document'), alert: 'Failed to update the document.'
	    end
	  else
	    redirect_to custom_provider_source_path(page: 'manage_document'), alert: 'Document or file not found.'
	  end
	end

	def delete_document
	  document = ProviderSourceDocument.find_by(id: params[:document_id])
	  if document && document.destroy
	    flash[:notice] = 'Document was successfully deleted.'
	    render json: { success: true }
	  else
	    flash[:alert] = 'Failed to delete the document.'
	    render json: { success: false }, status: :not_found
	  end
	end


	private

	def create_provider_source_and_redirect_to_edit_page
		current_provider_source.update(current_provider_source: false)
		ProviderSource.create!(current_provider_source: true)
		redirect_to custom_provider_source_path
	end

	def set_current_provider_source_and_redirect_to_edit_page
		current_provider_source.update(current_provider_source: false)
    provider_source = ProviderSource.find(params[:id])

    if provider_source.created_by_user.nil?
      ProviderSource.find(params[:id]).update(current_provider_source: true, created_by_user: current_user.id)
    else
      ProviderSource.find(params[:id]).update(current_provider_source: true)
    end
		redirect_to custom_provider_source_path
	end

	# Helper method to check if a file exists at a remote URL
	 def remote_file_exists?(url)
	  uri = URI.parse(url)
	  http = Net::HTTP.new(uri.host, uri.port)
	  http.use_ssl = true if uri.scheme == 'https'

	  request = Net::HTTP::Head.new(uri.request_uri)
	  response = http.request(request)

	  response.code.to_i == 200
	end
end

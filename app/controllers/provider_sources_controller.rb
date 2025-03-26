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

	# def autosave
	# 	return unless params[:field_name].present? && params[:value].present?

	# 	field_name = params[:field_name].parameterize(separator: '_')
	# 	value = params[:value]

	# 	data = current_provider_source.data.find_or_create_by(data_key: field_name)
	#   data.update_columns data_value: value.is_a?(Array) ? value.join(",") : value

	# 	respond_to do |format|
	# 			format.json { render json: { success: true, data_key: field_name, data_value: value } }
	# 	end
	# end

	def autosave
	  # === Deletion Logic ===
	  if params[:delete_other_name_id].present?
	    other_name = current_provider_source.other_names.find_by(id: params[:delete_other_name_id])
	    return other_name&.destroy ?
	      render(json: { message: "Deleted successfully!" }, status: :ok) :
	      render(json: { error: "Failed to delete" }, status: :unprocessable_entity)
	  end

	  if params[:delete_speciality_id].present?
	    specialty = current_provider_source.provider_source_specialities.find_by(id: params[:delete_speciality_id])
	    return specialty&.destroy ?
	      render(json: { message: "Specialty deleted successfully!" }, status: :ok) :
	      render(json: { error: "Failed to delete specialty" }, status: :unprocessable_entity)
	  end

	  # === Autosave Logic ===
	  field_name   = params[:field_name]
	  value        = params[:value]
	  specialty_id = params[:speciality_id] || params[:specialty_id]
	  other_name_id = params[:other_name_id]
	  nested_form  = ActiveModel::Type::Boolean.new.cast(params[:nested_form])

	  unless field_name.present? && value.present?
	    return render json: { error: "Missing field name or value" }, status: :bad_request
	  end

	  if field_name.include?("provider_source_specialities") && !nested_form
	    return render json: { error: "Invalid nested specialty save attempt" }, status: :forbidden
	  end

	  match = field_name.match(/\[(\d+)\]\[(\w+)\]$/)
	  unless match
	    return render json: { error: "Invalid field format" }, status: :unprocessable_entity
	  end

	  field = match[2]

	  record =
	    if field_name.include?("other_names")
	      other_name_id.present? ?
	        current_provider_source.other_names.find_or_initialize_by(id: other_name_id) :
	        current_provider_source.other_names.new
	    elsif field_name.include?("provider_source_specialities")
	      specialty_id.present? ?
	        current_provider_source.provider_source_specialities.find_or_initialize_by(id: specialty_id) :
	        current_provider_source.provider_source_specialities.new
	    else
	      return render json: { error: "Unknown nested attribute" }, status: :unprocessable_entity
	    end

	  unless record.respond_to?(field)
	    return render json: { error: "Invalid field: #{field}" }, status: :unprocessable_entity
	  end

	  # Only update if value changed or it's a new record

	  converted_value =
		  if record.has_attribute?(field) && record.column_for_attribute(field).type == :boolean
		    case value.to_s.strip.downcase
		    when "yes", "true", "1" then true
		    when "no", "false", "0" then false
		    else nil
		    end
		  else
		    value
		  end

	  if record.new_record? || record.send(field) != converted_value
	    # Convert "yes"/"no" to boolean if applicable
	    if record.has_attribute?(field) && record.column_for_attribute(field).type == :boolean
	      record[field] = case value.to_s.strip.downcase
	                      when "yes" then true
	                      when "no"  then false
	                      else value
	                      end
	    else
	      record[field] = value
	    end
	    if record.save
	      return render json: { message: "Saved successfully!", id: record.id }, status: :ok
	    else
	      Rails.logger.error "Autosave failed for #{record.class.name} - #{field}: #{value} | Errors: #{record.errors.full_messages.join(', ')}"
	      return render json: {
	        error: "Failed to save",
	        field: field,
	        attempted_value: value,
	        details: record.errors.full_messages
	      }, status: :unprocessable_entity
	    end
	  else
	    render json: { success: true, data_key: field_name, data_value: value }
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

	  other_names = current_provider_source.other_names.as_json(
	    only: [:id, :name_type, :first_name, :middle_name, :last_name, :suffix, :date_started, :date_stopped, :in_use]
	  )

	  specialties = current_provider_source.provider_source_specialities.as_json(
	    only: [
	      :id, :ranking, :specialty, :board_certified, :certifying_board, :address_line_1, :address_line_2, :city, :state,
	      :zipcode, :telephone, :ext, :fax_number, :bord_certificate_number, :initial_date, :exipration_date,
	      :recertification_date, :eligible_certified, :admissibility_expiration_date, :board_exam_results_pending,
	      :pending_certifying_board, :pending_address_line_1, :pending_address_line_2, :pending_city, :pending_state,
	      :pending_zipcode, :pending_telephone, :pending_ext, :pending_fax_number, :board_exam_date,
	      :applied_for_certification_exam, :accepted_for_certification_exam, :intend_applied_for_certification_exam,
	      :intend_date_apply, :specialties_no_board_exam_reason
	    ]
	  )

	  respond_to do |format|
	    format.json do
	      render json: {
	        value: filtered_value(data&.data_value, field_name),
	        other_names: other_names,
	        specialties: specialties
	      }
	    end
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

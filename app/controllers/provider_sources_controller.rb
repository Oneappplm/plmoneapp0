class ProviderSourcesController < ApplicationController
  before_action :set_current_provider_source_and_redirect_to_edit_page, only: [:edit]
  before_action :create_provider_source_and_redirect_to_edit_page, only: [:new]

  def new
  end

  def edit
  end

  def destroy
    @provider_source = ProviderSource.find(params[:id])
    @provider_source.destroy
    redirect_to provider_sources_path, notice: "Provider Source was successfully destroyed."
  end

  def index
    scope =
      if current_user.user_role == 'super_administrator' || current_user.user_role == 'administrator'
        ProviderSource.all
      else
        current_user.group_engage_provider&.provider_sources || ProviderSource.none
      end

    if params[:search].present?
      search_term = "%#{params[:search]}%"

      @provider_sources = scope
        .left_joins(:data)
        .where("provider_source_data.data_key IN ('first_name', 'last_name')")
        .where("provider_source_data.data_value ILIKE ?", search_term)
        .distinct
    else
      @provider_sources = scope.paginate(page: params[:page], per_page: params[:per_page] || 10)
    end

    @provider_source = ProviderSource.new
  end

  def autosave
    ps = editing_provider_source
    return render json: { error: "Provider source not found" }, status: :not_found unless ps.present?

    normalize_boolean = ->(val) do
      case val.to_s.strip.downcase
      when "yes", "true", "1" then true
      when "no", "false", "0" then false
      else nil
      end
    end

    if params[:delete_other_name_id].present?
      other_name = ps.other_names.find_by(id: params[:delete_other_name_id])
      return other_name&.destroy ?
        render(json: { message: "Deleted successfully!" }, status: :ok) :
        render(json: { error: "Failed to delete" }, status: :unprocessable_entity)
    end

    if params[:delete_speciality_id].present?
      specialty = ps.provider_source_specialities.find_by(id: params[:delete_speciality_id])
      return specialty&.destroy ?
        render(json: { message: "Specialty deleted successfully!" }, status: :ok) :
        render(json: { error: "Failed to delete specialty" }, status: :unprocessable_entity)
    end

    if params[:delete_undergraduate_school_id].present?
      school = ps.provider_source_undergrad_schools.find_by(id: params[:delete_undergraduate_school_id])
      return school&.destroy ?
        render(json: { message: "Undergraduate school deleted successfully!" }, status: :ok) :
        render(json: { error: "Failed to delete undergraduate school" }, status: :unprocessable_entity)
    end

    if params[:delete_graduate_detail_id].present?
      school = ps.graduate_details.find_by(id: params[:delete_graduate_detail_id])
      return school&.destroy ?
        render(json: { message: "Graduate/professional school deleted successfully!" }, status: :ok) :
        render(json: { error: "Failed to delete graduate school" }, status: :unprocessable_entity)
    end

    if params[:delete_privilege_id].present?
      privilege = ps.hospital_privileges.find_by(id: params[:delete_privilege_id])
      return privilege&.destroy ?
        render(json: { message: "hospital privileges deleted successfully!" }, status: :ok) :
        render(json: { error: "Failed to delete hospital privileges" }, status: :unprocessable_entity)
    end

    if params[:delete_admitting_id].present?
      admitting = ps.admitting_arrangements.find_by(id: params[:delete_admitting_id])
      return admitting&.destroy ?
        render(json: { message: "admitting arrangements deleted successfully!" }, status: :ok) :
        render(json: { error: "Failed to delete admitting arrangements" }, status: :unprocessable_entity)
    end

    field_name    = params[:field_name]
    value         = params[:value]
    specialty_id  = params[:speciality_id] || params[:specialty_id]
    other_name_id = params[:other_name_id]
    undergrad_id  = params[:undergraduate_school_id]
    graduate_id   = params[:graduate_school_id]
    privilege_id  = params[:privilege_id]
    admitting_id  = params[:admitting_id]
    model         = params[:model]
    nested_form   = ActiveModel::Type::Boolean.new.cast(params[:nested_form])

    unless field_name.present?
      return render json: { error: "Missing field name" }, status: :bad_request
    end

    model_training =
      if field_name.include?("tf-") || field_name.include?("tr_") || field_name.include?("tfu-")
        "training"
      end

    model_to_use = model.presence || model_training

    if %w[
      licensure medicare medicaid other_cert training liability malpractice
      military employment employment_gap prof_references prof_organization
      cred_contact prac_general_info prac_location_info
    ].include?(model_to_use)
      ProviderSources::AutosaveService.new(
        source: ps,
        field_name: field_name,
        value: value,
        model_id: nil,
        model: model_to_use
      ).perform
    end

    if model == "disclosure"
      ProviderSources::DisclosureAutosaveService.new(
        source: ps,
        field_name: params[:field_name],
        value: params[:value]
      ).perform
    end

    if defined?(update_cred_status!) && ps.persisted?
      begin
        update_cred_status!(ps)
      rescue NoMethodError => e
        Rails.logger.warn "⚠️ autosave: skipped cred status update (#{e.message})"
      end
    end

    match = field_name.match(/\[(\d+)\]\[(\w+)\]$/)

    if match
      field = match[2]

      record =
        if field_name.include?("other_names") && nested_form
          other_name_id.present? ? ps.other_names.find_or_initialize_by(id: other_name_id) : ps.other_names.new
        elsif field_name.include?("provider_source_specialities") && nested_form
          specialty_id.present? ? ps.provider_source_specialities.find_or_initialize_by(id: specialty_id) : ps.provider_source_specialities.new
        elsif field_name.include?("provider_source_undergrad_schools") && nested_form
          undergrad_id.present? ? ps.provider_source_undergrad_schools.find_or_initialize_by(id: undergrad_id) : ps.provider_source_undergrad_schools.new
        elsif field_name.include?("graduate_details") && nested_form
          graduate_id.present? ? ps.graduate_details.find_or_initialize_by(id: graduate_id) : ps.graduate_details.new
        elsif field_name.include?("hospital_privileges") && nested_form
          privilege_id.present? ? ps.hospital_privileges.find_or_initialize_by(id: privilege_id) : ps.hospital_privileges.new
        elsif field_name.include?("admitting_arrangements") && nested_form
          admitting_id.present? ? ps.admitting_arrangements.find_or_initialize_by(id: admitting_id) : ps.admitting_arrangements.new
        else
          return render json: { error: "Unknown nested attribute" }, status: :unprocessable_entity
        end

      if field_name.include?("other_names") && nested_form
        return handle_other_name_autosave(ps)
      elsif field_name.include?("provider_source_undergrad_schools") && nested_form
        return handle_education_autosave(ps)
      elsif field_name.include?("graduate_details") && nested_form
        return handle_education_autosave(ps)
      elsif field_name.include?("hospital_privileges") && nested_form
        return handle_hospital_privilege_autosave(ps)
      elsif field_name.include?("provider_source_specialities") && nested_form
        return handle_speciality_autosave(ps)
      end

      unless record.respond_to?(field)
        return render json: { error: "Invalid field: #{field}" }, status: :unprocessable_entity
      end

      converted_value =
        if record.has_attribute?(field) && record.column_for_attribute(field).type == :boolean
          normalize_boolean.call(value)
        else
          value
        end

      if record.new_record? ||
         record.public_send(field) != converted_value ||
         (record.has_attribute?(field) && record.column_for_attribute(field).type == :boolean)
        record[field] = converted_value

        if record.save
          return render json: { message: "Saved successfully!", id: record.id }, status: :ok
        else
          return render json: { error: "Failed to save", details: record.errors.full_messages }, status: :unprocessable_entity
        end
      else
        return render json: { success: true, data_key: field_name, data_value: value }, status: :ok
      end
    else
      mapped_attribute = ProviderPersonalInformation::FIELD_MAP[field_name]

      if mapped_attribute.present?
        personal_info = ps.provider_personal_information || ps.build_provider_personal_information

        if personal_info.respond_to?(mapped_attribute)
          value_to_store =
            if personal_info.has_attribute?(mapped_attribute) && personal_info.column_for_attribute(mapped_attribute).type == :boolean
              normalize_boolean.call(value)
            elsif value.is_a?(Array)
              value.join(",")
            else
              value
            end

          personal_info[mapped_attribute] = value_to_store
          personal_info.cred_status = "attested" if mapped_attribute.to_s == "attest_date"
          personal_info.save(validate: false)
        end
      end

      field_key = field_name.parameterize(separator: "_")
      data_record = ps.data.find_or_initialize_by(data_key: field_key)

      data_record.data_value =
        if data_record.has_attribute?(:data_value) && data_record.column_for_attribute(:data_value).type == :boolean
          normalize_boolean.call(value)
        else
          value.is_a?(Array) ? value.join(",") : value
        end

      if data_record.save
        render json: { success: true, data_key: field_key, data_value: value }, status: :ok
      else
        render json: { error: "Failed to save field data", details: data_record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

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
        redirect_to custom_provider_source_path(page: "manage_document")
      end
    end
  end

  def get_progress
    data_group = params[:data_group]
    provider = editing_provider_source

    return render json: { error: "Provider source not found" }, status: :not_found unless provider.present?
    return render json: { error: "Invalid progress group" }, status: :unprocessable_entity unless provider.respond_to?(data_group)

    render json: { progress: provider.public_send(data_group) }, status: :ok
  end

  def autosave_multi_record
    ps = editing_provider_source
    return render json: { error: "Provider source not found" }, status: :not_found unless ps.present?

    model = params[:model]
    id = params[:id]
    content = params[:content]
    field = params[:field]

    Rails.logger.debug ">>> AUTOSAVE_MULTI_RECORD: model=#{model}, id=#{id}, field=#{field}, content=#{content}"

    record_class =
      case model
      when "dea" then ProviderSourcesDea
      when "cds" then ProviderSourcesCds
      when "registration" then ProviderSourcesRegistration
      when "cme" then ProviderSourceCme
      end

    return head :bad_request unless record_class

    record = record_class.find_by(id: id)
    return head :not_found unless record

    if %w[dea cds].include?(model)
      ProviderSources::AutosaveService.new(
        source: ps,
        field_name: field,
        value: content,
        model_id: id,
        model: model
      ).perform
    end

    success = record.update(field => content)
    Rails.logger.debug ">>> Updated #{record_class.name} id=#{id} field=#{field} to #{content.inspect} => #{success}"
    render json: { success: success, field: field, value: content }
  end

  def fetch
    return unless params[:field_name].present?

    field_name = params[:field_name].parameterize(separator: "_")
    return if field_name.include?("provider_source_specialities")

    ps = editing_provider_source

    if ps.nil? || !ps.persisted?
      Rails.logger.warn "⚠️ fetch: editing_provider_source not persisted or nil"
      return render json: { value: nil }, status: :ok
    end

    data = ps.data.find_or_initialize_by(data_key: field_name)
    data.save if data.new_record? && ps.persisted?

    if data.data_value.blank? && params[:model_name].present?
      model_name = params[:model_name].to_s

      begin
        if ps.respond_to?(model_name)
          records = ps.public_send(model_name)
          record =
            if params[:record_id].present?
              records.find_by(id: params[:record_id])
            else
              records.last
            end

          if record&.respond_to?(field_name)
            data.data_value = record.public_send(field_name)
          end
        end
      rescue StandardError => e
        Rails.logger.warn "⚠️ fetch: Could not fetch nested model value for #{model_name}. Error: #{e.message}"
      end
    end

    render json: {
      value: filtered_value(data&.data_value, field_name)
    }, status: :ok
  end

  def filtered_value(field_value, field_name)
    case field_name
    when "ps-dob", "ps_dob"
      field_value.present? ? Date.parse(field_value).strftime("%Y-%m-%d") : ""
    else
      field_value
    end
  end

  def download_documents
    document_ids = params[:document_ids]
    documents = ProviderSourceDocument.where(id: document_ids)

    if documents.any?
      document = documents.first
      file_url = document.file_path.url

      if remote_file_exists?(file_url)
        redirect_to file_url, allow_other_host: true
      else
        redirect_back fallback_location: custom_provider_source_path(page: "manage_document"), alert: "Selected document could not be found for download."
      end
    else
      redirect_back fallback_location: custom_provider_source_path(page: "manage_document"), alert: "No documents found for download."
    end
  end

  def edit_document
    document = ProviderSourceDocument.find(params[:document_id])
    uploaded_file = params[:document_file]

    if document.present? && uploaded_file.present?
      document.file_path = uploaded_file
      document.file_name = uploaded_file.original_filename

      if document.save
        redirect_to custom_provider_source_path(page: "manage_document"), notice: "Document was successfully updated."
      else
        redirect_to custom_provider_source_path(page: "manage_document"), alert: "Failed to update the document."
      end
    else
      redirect_to custom_provider_source_path(page: "manage_document"), alert: "Document or file not found."
    end
  end

  def delete_document
    document = ProviderSourceDocument.find_by(id: params[:document_id])

    if document && document.destroy
      flash[:notice] = "Document was successfully deleted."
      render json: { success: true }
    else
      flash[:alert] = "Failed to delete the document."
      render json: { success: false }, status: :not_found
    end
  end

  private

  def update_cred_status!(provider_source = editing_provider_source)
    personal_info = provider_source&.provider_personal_information
    return unless personal_info.present?

    personal_info.cred_status =
      if personal_info.roster == "true"
        "no-application"
      elsif personal_info.verification_status == "completed" && personal_info.cred_status == "psv"
        "psv"
      elsif provider_source.general_info_completed? &&
            provider_source.professional_ids_completed? &&
            provider_source.health_plans_completed? &&
            provider_source.speacialties_completed? &&
            !all_information_completed?(provider_source)
        "pending"
      elsif personal_info.verification_status == "pending" && personal_info.attest_date.present?
        "attested"
      elsif personal_info.verification_status == "Processing" && personal_info.attest_date.present?
        "in-process"
      elsif all_information_completed?(provider_source) &&
            provider_source.all_sections_completed? &&
            personal_info.attest_date.present?
        "complete-application"
      else
        "incomplete"
      end

    personal_info.save(validate: false)
  end

  def handle_other_name_autosave(provider_source = editing_provider_source)
    result = ::ProviderSources::OtherNameAutosaveService.new(
      source: provider_source,
      field_name: params[:field_name],
      value: params[:value],
      other_name_id: params[:other_name_id]
    ).perform

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: result
    end
  end

  def handle_speciality_autosave(provider_source = editing_provider_source)
    result = ProviderSources::SpecialtyAutosaveService.new(
      source: provider_source,
      field_name: params[:field_name],
      value: params[:value],
      specialty_id: params[:speciality_id] || params[:specialty_id]
    ).perform

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: { message: "Saved successfully!", id: result[:id] }, status: :ok
    end
  end

  def handle_hospital_privilege_autosave(provider_source = editing_provider_source)
    result = ::ProviderSources::HospitalPrivilegeAutosaveService.new(
      source: provider_source,
      field_name: params[:field_name],
      value: params[:value],
      privilege_id: params[:privilege_id]
    ).perform

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: result
    end
  end

  def handle_education_autosave(provider_source = editing_provider_source)
    result = ::ProviderSources::ProviderEducationAutosaveService.new(
      source: provider_source,
      field_name: params[:field_name],
      value: params[:value],
      education_id: params[:undergraduate_school_id].presence || params[:graduate_school_id]
    ).perform

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: result
    end
  end

  def create_provider_source_and_redirect_to_edit_page
    gep = current_user.group_engage_provider

    unless gep
      return redirect_back fallback_location: root_path, alert: "Provider mapping missing"
    end

    gep.provider_sources.update_all(current_provider_source: false)

    provider_source = gep.provider_sources.create!(
      current_provider_source: true,
      created_by_user: current_user.id
    )

    redirect_to custom_provider_source_path(
      user_id: current_user.id,
      provider_source_id: provider_source.id
    )
  end

  def set_current_provider_source_and_redirect_to_edit_page
    provider_source = ProviderSource.find(params[:id])

    unless ["super_administrator", "administrator"].include?(current_user.user_role)
      unless provider_source.group_engage_provider == current_user.group_engage_provider
        return redirect_back fallback_location: provider_sources_path, alert: "Unauthorized"
      end
    end

    gep = provider_source.group_engage_provider
    gep.provider_sources.update_all(current_provider_source: false)
    provider_source.update(current_provider_source: true)

    redirect_to custom_provider_source_path(
      user_id: gep.user_id,
      provider_source_id: provider_source.id
    )
  end

  def remote_file_exists?(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    request = Net::HTTP::Head.new(uri.request_uri)
    response = http.request(request)

    response.code.to_i == 200
  end
end

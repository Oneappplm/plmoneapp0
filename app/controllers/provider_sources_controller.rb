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
		@provider_sources = ProviderSource.all
		@provider_source = ProviderSource.new
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
end
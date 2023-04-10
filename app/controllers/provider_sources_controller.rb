class ProviderSourcesController < ApplicationController
	def autosave
		return unless params[:field_name].present? && params[:value].present?

		field_name = params[:field_name].parameterize(separator: '_')
		value = params[:value]

		data = current_provider_source.data.find_or_create_by(data_key: field_name)
		data.data_value = value
		data.save

		respond_to do |format|
				format.json { render json: { success: true } }
		end
	end

	def fetch
		return unless params[:field_name].present?

		field_name = params[:field_name].parameterize(separator: '_')
		data = current_provider_source.data.find_or_create_by(data_key: field_name)

		respond_to do |format|
				format.json { render json: { value: data&.data_value } }
		end
	end
end
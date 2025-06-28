class ProviderSources::TransferToGroupEngageProvidersService < ProviderSource::BaseService
	attr_reader :group_engage_provider

	def initialize(provider_source)
		super

		@group_engage_provider = GroupEngageProvider.new
	end

	def call
		return unless provider_source.present?

		group_engage_initial_fields.each	do |column|
			data_key = filtered_data_key(column)

			group_engage_provider.send("#{column}=", provider_source.fetch(data_key))
		end

		group_engage_provider.save if group_engage_provider.valid?
	end
end

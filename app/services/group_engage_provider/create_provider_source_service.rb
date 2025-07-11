class GroupEngageProvider::CreateProviderSourceService < GroupEngageProvider::BaseService
	attr_reader	:provider_source

	def initialize(group_engage_provider)
		super

		@provider_source = ProviderSource.new(group_engage_provider_id:	group_engage_provider.id)
	end

	def call
		return error!("#{group_engage_provider.full_name} is already added in the Provider Engage.") if ProviderSource.exists?(group_engage_provider_id: group_engage_provider.id)

		save_provider_source_and_data_fields
	end

	protected
	def save_provider_source_and_data_fields
		if provider_source.save

			provider_source.increment!(:invitation_count)
			provider_source.update(invitation_sent_at: Time.now)

			group_engage_initial_fields.each	do |column|
				data_key = filtered_data_key(column)

				provider_source.add_data(data_key, group_engage_provider.send(column))

				if column == 'ssn' && group_engage_provider.ssn.present?
					provider_source.add_data('ps-ssn', 'yes')
				end
			end
		end
	end
end

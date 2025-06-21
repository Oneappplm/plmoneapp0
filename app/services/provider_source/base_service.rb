class ProviderSource::BaseService < BaseService
	attr_reader	:provider_source, :group_engage_initial_fields

	def initialize(provider_source)
		@provider_source = provider_source
		@group_engage_initial_fields = ['first_name', 'middle_name', 'last_name', 'date_of_birth', 'email_address', 'ssn']
	end

	protected
	def filtered_data_key column
		case column
		when 'date_of_birth'
			'ps_dob'
		when 'ssn'
			'social_security_number'
		else
			column
		end
	end
end

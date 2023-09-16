class GroupEngageProvider::BaseService < ApplicationService
	attr_reader :group_engage_provider, :group_engage_initial_fields

	def initialize(group_engage_provider)
		@group_engage_provider = group_engage_provider
		@group_engage_initial_fields = ['first_name', 'middle_name', 'last_name', 'date_of_birth', 'email_address', 'ssn']
	end

	protected
	def filtered_data_key column
		case column
		when 'date_of_birth'
			'ps-dob'
		when 'ssn'
			'social-security-number'
		else
			column
		end
	end
end

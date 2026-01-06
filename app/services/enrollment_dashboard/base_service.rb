class EnrollmentDashboard::BaseService < ApplicationService
	attr_reader :enrollment_provider, :enrollment_provider_initial_fields

	def initialize(enrollment_provider)
		@enrollment_provider = enrollment_provider
		@enrollment_provider_initial_fields = ['first_name', 'middle_name', 'last_name', 'date_of_birth', 'email_address', 'ssn']
	end
end

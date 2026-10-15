class EnrollmentDashboard::EnrollmentProviderService < EnrollmentDashboard::BaseService
	def initialize(provider)
		super

		@provider = provider   # ✅ FIX: save provider so it is accessible in other methods
   
	  # Create ProviderPersonalInformation with validations skipped
	  provider_personal_info = ProviderPersonalInformation.new(
	    first_name: @provider.first_name,
	    last_name: @provider.last_name,
	    ssn: @provider.ssn,
	    birth_date: @provider.birth_date,
	    middle_name: @provider.middle_name,
	    email_address: @provider.email_address,
		  caqh_provider_id: @provider.id,
		  provider_attest_id: rand(10**8).to_s.rjust(8, '5'),
		  caqh_provider_attest_id: rand(10**8).to_s.rjust(8, '5'), 
		  created_by: 'enrollment-provider',
		  cred_status: 'incomplete'
	  )

	  provider_personal_info.save(validate: false)

	  provider_attest = ProviderAttest.create!(
      id: provider_personal_info.provider_attest_id,
      caqh_provider_attest_id: provider_personal_info.caqh_provider_attest_id
    )

	  # @provider_source = ProviderSource.new(provider_id: provider.id, provider_personal_information_id: provider_personal_info.id)
	end

	def call
		return { success: false, error: "#{@provider.fullname} is already added in the Provider Engage." }
	end

	# protected
	# def save_provider_source_and_data_fields
	# 	if provider_source.save

	# 		provider_source.increment!(:invitation_count)
	# 		provider_source.update(invitation_sent_at: Time.now)

	# 		group_engage_initial_fields.each	do |column|
	# 			data_key = filtered_data_key(column)

	# 			provider_source.add_data(data_key, provider.send(column))

	# 			if column == 'ssn' && provider.ssn.present?
	# 				provider_source.add_data('ps-ssn', 'yes')
	# 			end
	# 		end
	# 	end
	# end
end

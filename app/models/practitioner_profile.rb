class PractitionerProfile < ApplicationRecord

	def self.generate_profiles
		profiles = [ 'PCP', 'Specialist', 'Urgent Care', 'Deliveries', 'Hospital Based',
					'OB', 'OB in your practice', 'Child Caring Institution', 'Comprehensive Outpatient Provider',
					'Crisis Residential', 'General Hospital with Psychiatric Unit ', 'Intensive Crisis Stabilization',
					'Partial Hospitalization – free standing', 'Partial Hospitalization – hospital based', 'Psychiatric Hospital',
					'Vocational Training', 'Other'
					]

    profiles.each do |profile|
      PractitionerProfile.find_or_create_by(name: profile)
    end
	end
end
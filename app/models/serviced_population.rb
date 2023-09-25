class ServicedPopulation < ApplicationRecord

	default_scope { order(:name)}

	def self.generate_serviced_populations
		populations = [ 'Adolescents', 'Autism', 'Co-Occurring', 'Dual Eligible/MI Health Link', 'Gender Non-Conforming', 'I/DD Adult', 'I/DD Child', 'Infant Mental Health', 'LGBTQ2S', 'Older Adults', 'Severe Emotional Disturbances (SED)', 'Severe Mentally Ill (SMI)', 'SOGIE', 'Substance Abuse', 'Transgender', 'Veterans', 'Women Specialty'
				]

		populations.each do |population|
			if !ServicedPopulation.exists?(name: population.strip)
				ServicedPopulation.create(name: population.strip)
			end
		end
	end

end
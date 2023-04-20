class PracticeType < ApplicationRecord

	def self.generate_types
		types = [
					'Academics', 'Associateship', 'HMO', 'Home Based',
					'Industry', 'Multi-Specialty Group', 'Partnership', 'Single Specialty Group', 'Solo Practice'
				]

		types.each do |practice_type|
			PracticeType.find_or_create_by(name: practice_type)
		end
	end

end
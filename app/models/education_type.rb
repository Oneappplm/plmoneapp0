class EducationType < ApplicationRecord

	def self.generate_types
		types = [
					'Graduate School', 'Professional School', 'Other'
				]

		types.each do |education_type|
			EducationType.find_or_create_by(name: education_type.strip)
		end
	end

end
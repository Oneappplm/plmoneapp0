class Hospital < ApplicationRecord
	default_scope { order(:name)}

	def self.generate_hospitals
		hospitals = ['Capital Medical Center', 'Coulee Medical Center', 'Evergreen Healthcare', 'Franciscan Health System',
					  'Island Hospital', 'Kittitas Valley Community Hospital', 'Lake Chelan Community Hospital', 'Mid Valley Hospital',
					  'Newport Hospital and Health', 'Prosser Memorial Hospital', 'Samaritan Healthcare', 'Snoqualmie Valley Hospital',
					  'WhidbeyHealth Medical Center', 'Central Washington Hospital', 'East Adams Rural Hospital', 'Fairfax Hospital',
					  'Garfield', 'Kaiser Permanente Washington', 'Klickitat Valley Health', 'Lourdes Healthcare', 'Multicare Health',
					  'Overlake Hospital Medical Center', 'Pullman Regional Hospital', 'Skagit Valley Hospital', 'Southwest Washington Med Ctr'
					]

		hospitals.each do |hospital|
			if !Hospital.exists?(name: hospital.strip)
				Hospital.create(name: hospital.strip)
			end
		end
	end
end
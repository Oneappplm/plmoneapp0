class DisclosureCategory < ApplicationRecord
	has_many :questions, class_name: 'DisclosureQuestion'

	def self.generate_categories
		categories = [['Licensure',nil,nil],['Hospital Privileges and Other Affiliations',nil,nil],
					  ['Education, Training and Board Certification',nil,nil], ['DEA or CDS',nil,nil],
					  ['Medicare, Medicaid or Other Governmental Program Participation',nil,nil],
					  ['Other Sanctions or Investigations',nil,nil], ['Malpractice Claims History',' If Yes, please complete the claim information fields on the Professional Liability Coverage and Claims History form for each professional liability action. ', 'alert alert-warning'],
					  ['Professional Liability Insurance Information and Claims History',nil,nil],
					  ['Criminal/Civil History*', nil,nil], ['Ability To Perform Job',nil,nil]
					]

		categories.each do |category|
			if !DisclosureCategory.exists?(title: category[0])
				DisclosureCategory.create(title: category[0], note: category[1], alert_type: category[2])
			end
		end
	end

end
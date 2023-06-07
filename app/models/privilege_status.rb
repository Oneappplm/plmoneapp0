class PrivilegeStatus < ApplicationRecord
  default_scope { order(:name)}

	def self.generate_privileges
		privileges = [
                 'Active', 'Adjunctive', 'Admitting', 'Affiliate', 'Associate', 'Attending', 'Co-Admissions', 'Consulting-Admitting', 'Courtesy', 'Emeritus', 'Non-admitting', 'Pending', 'Provisional', 'Senior', 'Staff', 'Temporary-Admitting', 'None'
                  ]

    privileges.each do |privilege|
      PrivilegeStatus.find_or_create_by(name: privilege.strip)
    end
	end
end
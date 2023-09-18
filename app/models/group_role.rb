class GroupRole < ApplicationRecord
	default_scope { order(:name)}

	def self.generate_group_roles
		group_roles = ['Director or Officers', 'DO Delegated Official', 'Managing Employee', 'AO Authorized Official',
					  'Partner', 'W2 Employee', 'PECOS AO Authorized Official', 'PECOS AM Access Manager'
					]

      group_roles.each do |group_role|
			if !GroupRole.exists?(name: group_role.strip)
				GroupRole.create(name: group_role.strip)
			end
		end
	end
end
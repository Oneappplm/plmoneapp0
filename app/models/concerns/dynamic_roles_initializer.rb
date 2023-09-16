module DynamicRolesInitializer
 extend ActiveSupport::Concern

	included do
		roles = 	self.pluck(:user_role).uniq + Role.all.map{|role| role.name.strip.parameterize.gsub('-','_') }.uniq

		roles.uniq.each do |role|
			define_method "#{role}?" do
				user_role == role
			end
		end
	end
end

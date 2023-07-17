module DynamicRolesInitializer
 extend ActiveSupport::Concern

	included do
		self.pluck(:user_role).uniq.each do |role|
			define_method "#{role}?" do
				user_role == role
			end
		end
	end
end

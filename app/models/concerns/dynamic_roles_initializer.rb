module DynamicRolesInitializer
 extend ActiveSupport::Concern

	included do
		def method_missing(method_name, *args, &block)
			if method_name.to_s.end_with?("?")
				role_name = method_name.to_s.chomp("?") # Remove trailing "?" if present
				role.downcase.parameterize(separator: '_') == role_name.downcase
			else
				super
			end
		end

		def self.method_missing(method_name, *args, &block)
			if method_name.to_s.start_with?("pick_")
				role_name = method_name.to_s.sub("pick_", "") # Remove leading "pick_" if present
				role_name = role_name.downcase.parameterize(separator: '_')
				find_by(user_role: role_name)
			else
				super
			end
		end
	end
end

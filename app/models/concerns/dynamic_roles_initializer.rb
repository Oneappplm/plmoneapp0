module DynamicRolesInitializer
 extend ActiveSupport::Concern

	included do
		def method_missing(method_name, *args, &block)
				role_name = method_name.to_s.chomp("?") # Remove trailing "?" if present
				role.downcase == role_name.downcase
		end
	end
end

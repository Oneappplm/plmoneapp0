module RolesHelper
	def can_view? page, role_based	= nil
		return false unless page.present?

		find_role(page.to_role, role_based)&.can_read
	end

	def find_role page, role_based = nil
		role = role_based || current_user.current_role

		RoleBasedAccess.find_by(page: page, role: role) rescue	nil
	end

	def access_denied
		# must be converted to partial to be compatible with role-based access
		render partial: 'shared/access_denied'
	end

	def redirect_to_filtered_page page
		return if page == 'overview'
		case page
		when 'verification_platform', 'enrollment_clients', 'office_manager', 'settings', 'manage_clients', 'manage_practitioners', 'work_ticklers'
			redirect_to controller: page, action: 'index'
		when 'client_portal', 'plm_sales_tool', 'smart_contract'
				redirect_to send("#{page}_path")
		when 'enrollment_tracking'
			redirect_to overview_providers_path
		when 'provider_app'
			redirect_to custom_provider_source_path
		else
			render partial: 'shared/access_denied' and return
		end
	end
end

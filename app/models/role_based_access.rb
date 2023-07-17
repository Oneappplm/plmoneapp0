class RoleBasedAccess < ApplicationRecord
	PAGES = [
		:overview,
		# :client_portal_data_access, :client_portal_vrc, :client_portal_clients, :client_portal_systems, :client_portal_reports, :client_portal_service, :client_portal_screening, :client_portal_support,
		# :client_portal_data_access, :client_portal_vrc, :client_portal_clients, :client_portal_systems,
		:client_portal,
		:provider_app,
		:office_manager,
		:enrollment_tracking,
		:verification_platform,
		:plm_sales_tool,
		:smart_contract,
		:settings,
		:manage_clients,
		:manage_practitioners,
		:work_ticklers,
  :enrollment_clients,
	]
	CRUD = [:create, :read, :update, :delete]

	default_scope { order(:id) }

	class << self
		def initialize_access(role_based = 'super_administrator')
			return unless role_based.present?

			PAGES.each do |page|
				RoleBasedAccess.find_or_create_by(role: role_based, page: page)
			end

			if role_based == 'super_administrator'
				RoleBasedAccess.where(role: role_based).each do |access|
					CRUD.each do |crud|
						access.update_attribute("can_#{crud}", true) if access.send("can_#{crud}").nil?
					end
				end
			end
		end
	end
end
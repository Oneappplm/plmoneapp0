class RoleBasedAccess < ApplicationRecord
	PAGES = [:overview, :client_portal, :virtual_review_committee, :organization_profile, :provider_app, :office_manager, :enrollment_tracking, :verification_platform, :plm_sales_tool, :smart_contract]
	CRUD = [:create, :read, :update, :delete]

	default_scope { order(:id) }

	class << self
		def initialize_access(role_based = 'administrator')
			return unless role_based.present?

			PAGES.each do |page|
				RoleBasedAccess.find_or_create_by(role: role_based, page: page)
			end

			if role_based == 'administrator'
				RoleBasedAccess.where(role: role_based).each do |access|
					CRUD.each do |crud|
						access.update_attribute("can_#{crud}", true) if access.send("can_#{crud}").nil?
					end
				end
			end
		end
	end
end
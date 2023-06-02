class RoleBasedAccessesController < ApplicationController
	def index
		if params[:role_based].present?
			@role_based = params[:role_based]
			RoleBasedAccess.initialize_access(@role_based)
		end
	end

	def update_access
		role_based_access = RoleBasedAccess.find(params[:id])
		role_based_access.update_attribute("#{params[:attribute_name]}", params[:attribute_value]) if role_based_access.present?
	end
end
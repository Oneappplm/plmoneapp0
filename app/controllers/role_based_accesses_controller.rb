class RoleBasedAccessesController < ApplicationController
	before_action :can_read?, only: [:index]
	before_action :can_update?, only: [:update_access]

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

	def can_read?
		return if current_user&.admin?
		super
	end

	def can_update?
		return if current_user&.admin?
		super
	end
end
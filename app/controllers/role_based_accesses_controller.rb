class RoleBasedAccessesController < ApplicationController
	def index
		# set role based access, default to current user's role
		@role_based = params[:role_based] || current_user.current_role

		# find or create role based access
		RoleBasedAccess.initialize_access(@role_based)

		# set class variable to be used in role_based_access_checkbox
		HtmlUtils.role_based = @role_based
	end

	def update_access
		# this will be call when role	based access checkbox is checked or	unchecked

		#	find role based access by id
		role_based_access = RoleBasedAccess.find(params[:id])

		# update role based access - can_read will be the indicator	if the user can access the page
		role_based_access.update_attribute(:can_read, params[:attribute_value]) if role_based_access.present?

		# render json response
		render json: { role_based_access: role_based_access }
	end

	def delete_role
		# # find role based access by role
		role_based_access = RoleBasedAccess.find_by_role(params[:role])

		# validate if role based has many users
		if role_based_access.users.count > 0
			# render json response
			render json: "Unable to delete role that is already assigned to user." , status: :unprocessable_entity
		else
			# delete all role based access

			role_based_access.parent_role.destroy! if role_based_access.present? && role_based_access.parent_role.present?

			flash[:notice] = "Role has been successfully deleted."

			head :no_content
		end
	end
end
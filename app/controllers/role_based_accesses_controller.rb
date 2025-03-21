class RoleBasedAccessesController < ApplicationController
  def index
    @role_based = params[:role_based] || current_user.current_role

    RoleBasedAccess.initialize_access(@role_based)

    @query = params[:query].presence
    @permissions = RoleBasedAccess.where(role: @role_based)
    @permissions = @permissions.where("page ILIKE ?", "%#{@query}%") if @query
    @permissions = @permissions.order(:page).group_by(&:page)

    HtmlUtils.role_based = @role_based
  end

  def update_permissions
    params[:permissions]&.each do |id, actions|
      access = RoleBasedAccess.find_by(id: id)
      next unless access

      full_access = actions["full_access"] == "1"

      access.update(
        can_read: full_access || actions["read"].present?,
        can_update: full_access || actions["write"].present?,
        can_create: full_access || actions["create"].present?,
        can_delete: full_access || actions["delete"].present?
      )
    end
    redirect_to role_based_accesses_path(role_based: params[:role_based]), notice: "Permissions updated successfully."
  end

  def delete_role
		role_based_access = RoleBasedAccess.find_by_role(params[:role])

		if role_based_access.users.count > 0
			render json: "Unable to delete role that is already assigned to user." , status: :unprocessable_entity
		else
			role_based_access.parent_role.destroy! if role_based_access.present? && role_based_access.parent_role.present?

			flash[:notice] = "Role has been successfully deleted."

			head :no_content
		end
  end
end

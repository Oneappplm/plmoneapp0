class UpdateRoleBasedAccessRoleViewerToProvider < ActiveRecord::Migration[7.0]
  def change
    RoleBasedAccess.where(role: 'viewer').update_all(role: 'provider')
  end
end

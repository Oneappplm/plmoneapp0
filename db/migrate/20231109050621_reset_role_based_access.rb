class ResetRoleBasedAccess < ActiveRecord::Migration[7.0]
  def change
			RoleBasedAccess.delete_all
			RoleBasedAccess.initialize_access
  end
end

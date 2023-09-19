class RunGroupRolesImportScript < ActiveRecord::Migration[7.0]
  def change
    GroupRole.generate_group_roles
  end
end

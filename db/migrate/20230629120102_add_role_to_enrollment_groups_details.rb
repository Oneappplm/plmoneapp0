class AddRoleToEnrollmentGroupsDetails < ActiveRecord::Migration[7.0]
  def up
    add_column :enrollment_groups_details, :roles, :string
  end

  def down
    remove_column :enrollment_groups_details, :roles, :string
  end
end

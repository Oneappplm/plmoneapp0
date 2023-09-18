class AddNewGroupRolesToEnrollmentGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups_details, :group_role, :string
  end
end

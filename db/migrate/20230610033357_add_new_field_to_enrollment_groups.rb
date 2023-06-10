class AddNewFieldToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :group_personnel_name, :string
    add_column :enrollment_groups, :group_personnel_email, :string
    add_column :enrollment_groups, :group_personnel_phone_number, :string
    add_column :enrollment_groups, :group_personnel_fax_number, :string
    add_column :enrollment_groups, :group_personnel_position, :string
  end
end
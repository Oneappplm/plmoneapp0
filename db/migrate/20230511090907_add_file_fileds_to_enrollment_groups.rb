class AddFileFiledsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :cp575_file, :string
    add_column :enrollment_groups, :specific_type_file, :string
    add_column :enrollment_groups, :ownership_file, :string
  end
end

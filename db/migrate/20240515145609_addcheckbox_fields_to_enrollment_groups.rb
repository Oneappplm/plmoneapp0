class AddcheckboxFieldsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :rcm_only, :boolean, default: false
  end
end
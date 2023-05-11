class AddNewFieldToGroupDcos < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :inpatient_facility, :string
    add_column :group_dcos, :is_clinic, :string
    add_column :group_dcos, :telehealth_provider, :string
  end
end

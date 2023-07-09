class AddOldPracticeLocationFieldsToGroupDco < ActiveRecord::Migration[7.0]
  def up
    add_column :group_dcos, :old_address, :string
    add_column :group_dcos, :old_city, :string
    add_column :group_dcos, :old_state, :string
    add_column :group_dcos, :old_county, :string
    add_column :group_dcos, :old_zipcode, :string
    add_column :group_dcos, :is_old_location_primary, :boolean
  end

  def down
    remove_column :group_dcos, :old_address, :string
    remove_column :group_dcos, :old_city, :string
    remove_column :group_dcos, :old_state, :string
    remove_column :group_dcos, :old_county, :string
    remove_column :group_dcos, :old_zipcode, :string
    remove_column :group_dcos, :is_old_location_primary, :boolean
  end
end

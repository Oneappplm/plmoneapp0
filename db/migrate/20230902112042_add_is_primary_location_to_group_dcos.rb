class AddIsPrimaryLocationToGroupDcos < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :is_primary_location, :boolean
  end
end

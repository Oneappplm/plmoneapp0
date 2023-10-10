class AddNewDropdownToDcos < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :location_status, :string
  end
end

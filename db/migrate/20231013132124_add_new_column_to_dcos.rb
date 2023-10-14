class AddNewColumnToDcos < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :location_npi, :string
    add_column :group_dcos, :location_tin, :string
  end
end

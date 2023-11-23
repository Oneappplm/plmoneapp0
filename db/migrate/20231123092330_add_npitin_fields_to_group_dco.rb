class AddNpitinFieldsToGroupDco < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :npi_digits, :string
    add_column :group_dcos, :tin_digits_type, :string
  end
end
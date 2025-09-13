class ChangeColumnTypeRvaInformation < ActiveRecord::Migration[7.0]
  def up
    change_column :rva_informations, :adverse_action, :string
  end

  def down
    change_column :rva_informations, :adverse_action, :boolean
  end
end

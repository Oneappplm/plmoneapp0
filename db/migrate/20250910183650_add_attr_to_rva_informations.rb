class AddAttrToRvaInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :rva_informations, :adverse_action_type, :string
  end
end

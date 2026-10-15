class AddAttrToPracticeInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_informations, :tin_number, :string
  end
end

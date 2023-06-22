class AddClientNameToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :client_name, :string
  end
end

class AddAccessibleProviderToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :accessible_provider, :string
  end
end

class AddIsProviderAccountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_provider_account, :boolean
  end
end

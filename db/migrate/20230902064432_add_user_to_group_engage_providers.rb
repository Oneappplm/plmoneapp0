class AddUserToGroupEngageProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :group_engage_providers, :user_id, :integer
  end
end

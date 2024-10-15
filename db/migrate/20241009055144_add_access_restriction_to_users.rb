class AddAccessRestrictionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :assigned_access_only, :boolean
  end
end

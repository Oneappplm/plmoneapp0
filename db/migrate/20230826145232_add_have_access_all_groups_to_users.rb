class AddHaveAccessAllGroupsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :can_access_all_groups, :boolean
  end
end

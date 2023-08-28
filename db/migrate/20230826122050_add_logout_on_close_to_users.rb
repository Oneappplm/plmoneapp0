class AddLogoutOnCloseToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :logout_on_close, :boolean, default: false
    add_column :users, :last_logout_on_close, :datetime, default: nil, null: true
  end
end

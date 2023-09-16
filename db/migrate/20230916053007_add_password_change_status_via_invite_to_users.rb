class AddPasswordChangeStatusViaInviteToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :password_change_status_via_invite, :string
  end
end

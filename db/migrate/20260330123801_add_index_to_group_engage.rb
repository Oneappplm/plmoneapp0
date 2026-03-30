class AddIndexToGroupEngage < ActiveRecord::Migration[7.0]
  def change
    add_index :group_engage_providers, :user_id, unique: true
  end
end

class AddOtherColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :following_request, :string
    add_column :users, :middle_name, :string
    add_column :users, :suffix, :string
    add_column :users, :status, :string
    add_column :users, :from_source, :string
  end
end

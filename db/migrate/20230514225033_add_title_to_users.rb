class AddTitleToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :title, :string
  end

  def down
    remove_column :users, :title, :string
  end
end

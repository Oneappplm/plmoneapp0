class CreateUserSidebarPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_sidebar_preferences do |t|
      t.references :user
      t.string :collapse_name
      t.boolean :is_open, default: true

      t.timestamps
    end
  end
end

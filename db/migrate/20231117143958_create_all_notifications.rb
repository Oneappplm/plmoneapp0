class CreateAllNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :all_notifications do |t|
      t.string :description

      t.timestamps
    end
  end
end

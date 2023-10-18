class CreateAddSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :add_schedules do |t|
      t.string :group_name
      t.text :description

      t.timestamps
    end
    add_column :add_schedules, :add_members, :string, array: true, default: []
  end
end

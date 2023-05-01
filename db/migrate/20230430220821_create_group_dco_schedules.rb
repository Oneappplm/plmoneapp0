class CreateGroupDcoSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :group_dco_schedules do |t|
      t.references :group_dco
      t.string :day
      t.string :start_time
      t.string :end_time

      t.timestamps
    end
  end
end

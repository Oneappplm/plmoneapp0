class AddMoreFieldsToPracticeLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_locations, :monday_time_start_2, :time
    add_column :practice_locations, :monday_time_end_2, :time

    add_column :practice_locations, :tuesday_time_start_2, :time
    add_column :practice_locations, :tuesday_time_end_2, :time

    add_column :practice_locations, :wednesday_time_start_2, :time
    add_column :practice_locations, :wednesday_time_end_2, :time

    add_column :practice_locations, :thursday_time_start_2, :time
    add_column :practice_locations, :thursday_time_end_2, :time

    add_column :practice_locations, :friday_time_start_2, :time
    add_column :practice_locations, :friday_time_end_2, :time

    add_column :practice_locations, :saturday_time_start_2, :time
    add_column :practice_locations, :saturday_time_end_2, :time

    add_column :practice_locations, :sunday_time_start_2, :time
    add_column :practice_locations, :sunday_time_end_2, :time
  end
end

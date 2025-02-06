class CreatePracticeHours < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_hours, primary_key: [:provider_attest_id,:provider_practice_hours_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_hours_id
      t.references    :provider_attest
      t.boolean       :no_office_hours_flag
      t.string        :morning_hours
      t.string        :afternoon_hours
      t.string        :evening_hours
      t.string        :office_hours
      t.string        :evening_weekend_hours
      t.boolean       :evening_hours_flag
      t.boolean       :weekend_hours_flag
      t.string        :start_hours_hours
      t.text          :hours_type_hours_type_description
      t.string        :end_hours_hours
      t.string        :day_of_week_day_of_week_name
      t.integer       :provider_practice_id

      t.timestamps
    end

    add_index  :practice_hours, :provider_practice_id, :name => 'ph_pp_id'
  end

  def self.down
    drop_table :practice_hours
  end
end

class CreatePracticeHours < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_hours do |t|
      t.integer       :caqh_provider_practice_hours_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
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
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id

      t.timestamps
    end
  end

  def self.down
    drop_table :practice_hours
  end
end

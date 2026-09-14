class CreatePracticeLimitations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_limitations do |t|
      t.integer       :caqh_provider_practice_limitation_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.boolean       :age_limitation_flag
      t.integer       :age_limitation_minimum
      t.integer       :age_limitation_maximum
      t.text          :other_limitation_description
      t.boolean       :specialty_limitation_flag
      t.text          :specialty_limitation_description
      t.text          :gender_limitation_gender_limitation_description
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_limitations
  end
end

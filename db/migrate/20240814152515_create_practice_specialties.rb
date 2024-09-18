class CreatePracticeSpecialties < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_specialties do |t|
      t.integer      :caqh_provider_practice_specialty_id
      t.references   :provider_attest
      t.integer      :caqh_provider_attest_id
      t.integer      :specialty_percent
      t.boolean      :primary_care_flag
      t.boolean      :specialty_care_flag
      t.boolean      :multi_care_flag
      t.string       :specialty_specialty_name
      t.string       :sub_specialty_specialty_name
      t.text         :specialty_type_specialty_type_description
      t.references   :practice_information
      t.integer      :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_specialties
  end
end

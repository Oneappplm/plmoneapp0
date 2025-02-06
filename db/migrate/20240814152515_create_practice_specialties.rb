class CreatePracticeSpecialties < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_specialties, primary_key: [:provider_attest_id,:provider_practice_specialty_id,:provider_practice_id] do |t|
      t.integer      :provider_practice_specialty_id
      t.references   :provider_attest
      t.integer      :specialty_percent
      t.boolean      :primary_care_flag
      t.boolean      :specialty_care_flag
      t.boolean      :multi_care_flag
      t.string       :specialty_specialty_name
      t.string       :sub_specialty_specialty_name
      t.text         :specialty_type_specialty_type_description
      t.integer      :provider_practice_id
      t.timestamps
    end

    add_index  :practice_specialties, :provider_practice_id, :name => 'pspecial_pp_id'
  end

  def self.down
    drop_table :practice_specialties
  end
end

class CreatePracticeLimitations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_limitations, primary_key: [:provider_attest_id,:provider_practice_limitation_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_limitation_id
      t.references    :provider_attest
      t.boolean       :age_limitation_flag
      t.integer       :age_limitation_minimum
      t.integer       :age_limitation_maximum
      t.text          :other_limitation_description
      t.boolean       :specialty_limitation_flag
      t.text          :specialty_limitation_description
      t.text          :gender_limitation_gender_limitation_description
      t.integer       :provider_practice_id
      t.timestamps
    end

    add_index  :practice_limitations, :provider_practice_id, :name => 'plimit_pp_id'
  end

  def self.down
    drop_table :practice_limitations
  end
end

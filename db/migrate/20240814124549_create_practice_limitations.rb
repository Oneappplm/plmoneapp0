class CreatePracticeLimitations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_limitations, id: false do |t|
      t.primary_key   :provider_practice_limitation_id
      t.references    :provider_attest
      t.boolean       :age_limitation_flag
      t.integer       :age_limitation_minimum
      t.integer       :age_limitation_maximum
      t.text          :other_limitation_description
      t.boolean       :specialty_limitation_flag
      t.text          :specialty_limitation_description
      t.text          :gender_limitation_gender_limitation_description

      t.timestamps
    end

    add_column :practice_limitations, :provider_practice_id, :integer
    add_index  :practice_limitations, :provider_practice_id, :name => 'plimit_pp_id'
  end

  def self.down
    drop_table :practice_limitations
  end
end

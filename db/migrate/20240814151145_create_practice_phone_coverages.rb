class CreatePracticePhoneCoverages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_phone_coverages do |t|
      t.integer       :caqh_provider_practice_phone_coverage_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.boolean       :phone_coverage_flag
      t.text          :phone_coverage_type_description
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_phone_coverages
  end
end

class CreatePracticeAccessibilities < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_accessibilities do |t|
      t.integer     :caqh_provider_practice_accessibility_id
      t.references  :provider_attest
      t.integer     :caqh_provider_attest_id
      t.boolean     :accessibility_flag
      t.text        :other_accessibility_description
      t.text        :accessibility_accessibility_description
      t.references  :practice_information
      t.integer     :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_accessibilities
  end
end

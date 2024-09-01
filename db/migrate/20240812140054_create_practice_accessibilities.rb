class CreatePracticeAccessibilities < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_accessibilities, primary_key: [:provider_attest_id, :provider_practice_accessibility_id, :provider_practice_id] do |t|
      t.integer     :provider_practice_accessibility_id
      t.references  :provider_attest
      t.boolean     :accessibility_flag
      t.text        :other_accessibility_description
      t.text        :accessibility_accessibility_description
      t.integer     :provider_practice_id
      t.timestamps
    end

    add_index  :practice_accessibilities, :provider_practice_id
  end

  def self.down
    drop_table :practice_accessibilities
  end
end

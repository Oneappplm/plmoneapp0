class CreatePracticeAccessibilities < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_accessibilities, id: false do |t|
      t.primary_key :provider_practice_accessibility_id
      t.references  :provider_attest
      t.boolean     :accessibility_flag
      t.text        :other_accessibility_description
      t.text        :accessibility_accessibility_description

      t.timestamps
    end

    add_column :practice_accessibilities, :provider_practice_id, :integer
    add_index  :practice_accessibilities, :provider_practice_id
  end

  def self.down
    drop_table :practice_accessibilities
  end
end

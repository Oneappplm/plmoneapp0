class CreatePracticeTaxIds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_tax_ids do |t|
      t.integer      :caqh_provider_practice_tax_id
      t.references   :provider_attest
      t.integer      :caqh_provider_attest_id
      t.string       :group_name
      t.string       :tax_id
      t.boolean      :primary_flag
      t.string       :group_number
      t.text         :tax_type_tax_type_description
      t.references   :practice_information
      t.integer      :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_tax_ids
  end
end

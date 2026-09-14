class CreatePracticeOtherTaxIds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_other_tax_ids do |t|
      t.integer       :caqh_provider_practice_other_tax_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.string        :tax_id
      t.references    :practice_information
      t.references    :practice_other_question
      t.integer       :caqh_provider_practice_id
      t.integer       :caqh_provider_practice_other_id

      t.timestamps
    end
  end

  def self.down
    drop_table :practice_other_tax_ids
  end
end

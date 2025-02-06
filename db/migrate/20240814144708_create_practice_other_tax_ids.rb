class CreatePracticeOtherTaxIds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_other_tax_ids, primary_key: [:provider_attest_id,:provider_practice_other_tax_id,:provider_practice_other_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_other_tax_id
      t.references    :provider_attest
      t.string        :tax_id
      t.integer       :provider_practice_id
      t.integer       :provider_practice_other_id
      t.timestamps
    end

    add_index  :practice_other_tax_ids, :provider_practice_id, :name => 'poti_pp_id'
    add_index  :practice_other_tax_ids, :provider_practice_other_id, :name => 'poti_poq_id'

  end

  def self.down
    drop_table :practice_other_tax_ids
  end
end

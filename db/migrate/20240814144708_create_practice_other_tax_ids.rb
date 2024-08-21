class CreatePracticeOtherTaxIds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_other_tax_ids, id: false do |t|
      t.primary_key   :provider_practice_other_tax_id
      t.references    :provider_attest
      t.string        :tax_id

      t.timestamps
    end

    add_column :practice_other_tax_ids, :provider_practice_id, :integer
    add_column :practice_other_tax_ids, :provider_practice_other_id, :integer

    add_index  :practice_other_tax_ids, :provider_practice_id, :name => 'poti_pp_id'
    add_index  :practice_other_tax_ids, :provider_practice_other_id, :name => 'poti_poq_id'

  end

  def self.down
    drop_table :practice_other_tax_ids
  end
end

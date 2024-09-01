class CreatePracticeTaxIds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_tax_ids, primary_key: [:provider_attest_id,:provider_practice_tax_id,:provider_practice_id] do |t|
      t.integer      :provider_practice_tax_id
      t.references   :provider_attest
      t.string       :group_name
      t.string       :tax_id
      t.boolean      :primary_flag
      t.string       :group_number
      t.text         :tax_type_tax_type_description
      t.integer      :provider_practice_id
      t.timestamps
    end

    add_index  :practice_tax_ids, :provider_practice_id, :name => 'p_tax_pp_id'
  end

  def self.down
    drop_table :practice_tax_ids
  end
end

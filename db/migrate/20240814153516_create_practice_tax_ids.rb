class CreatePracticeTaxIds < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_tax_ids, id: false do |t|
      t.primary_key  :provider_practice_tax_id
      t.references   :provider_attest
      t.string       :group_name
      t.string       :tax_id
      t.boolean      :primary_flag
      t.string       :group_number
      t.text         :tax_type_tax_type_description

      t.timestamps
    end

    add_column :practice_tax_ids, :provider_practice_id, :integer
    add_index  :practice_tax_ids, :provider_practice_id, :name => 'p_tax_pp_id'
  end

  def self.down
    drop_table :practice_tax_ids
  end
end

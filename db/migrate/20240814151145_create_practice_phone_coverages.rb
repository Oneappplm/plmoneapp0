class CreatePracticePhoneCoverages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_phone_coverages, id: false do |t|
      t.primary_key   :provider_practice_phone_coverage_id
      t.references    :provider_attest
      t.boolean       :phone_coverage_flag
      t.text          :phone_coverage_type_description

      t.timestamps
    end

    add_column :practice_phone_coverages, :provider_practice_id, :integer
    add_index  :practice_phone_coverages, :provider_practice_id, :name => 'ppc_id'
  end

  def self.down
    drop_table :practice_phone_coverages
  end
end

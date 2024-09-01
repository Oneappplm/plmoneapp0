class CreatePracticePhoneCoverages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_phone_coverages, primary_key: [:provider_attest_id,:provider_practice_phone_coverage_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_phone_coverage_id
      t.references    :provider_attest
      t.boolean       :phone_coverage_flag
      t.text          :phone_coverage_type_description
      t.integer       :provider_practice_id
      t.timestamps
    end

    add_index  :practice_phone_coverages, :provider_practice_id, :name => 'ppc_id'
  end

  def self.down
    drop_table :practice_phone_coverages
  end
end

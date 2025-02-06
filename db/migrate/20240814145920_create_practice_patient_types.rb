class CreatePracticePatientTypes < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_patient_types, primary_key: [:provider_attest_id,:provider_practice_patient_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_patient_id
      t.references    :provider_attest
      t.boolean       :patient_flag
      t.text          :patient_explanation
      t.text          :patient_type_patient_type_description
      t.integer       :provider_practice_id
      t.timestamps
    end

    add_index  :practice_patient_types, :provider_practice_id, :name => 'ppt_id'
  end

  def self.down
    drop_table :practice_patient_types
  end
end

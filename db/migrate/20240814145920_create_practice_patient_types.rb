class CreatePracticePatientTypes < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_patient_types do |t|
      t.integer       :caqh_provider_practice_patient_id
      t.references    :provider_attest
      t.integer       :caqh_provider_attest_id
      t.boolean       :patient_flag
      t.text          :patient_explanation
      t.text          :patient_type_patient_type_description
      t.references    :practice_information
      t.integer       :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_patient_types
  end
end

class CreatePracticePatientTypes < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_patient_types, id: false do |t|
      t.primary_key   :provider_practice_patient_id
      t.references    :provider_attest
      t.boolean       :patient_flag
      t.text          :patient_explanation
      t.text          :patient_type_patient_type_description

      t.timestamps
    end

    add_column :practice_patient_types, :provider_practice_id, :integer
    add_index  :practice_patient_types, :provider_practice_id, :name => 'ppt_id'
  end

  def self.down
    drop_table :practice_patient_types
  end
end

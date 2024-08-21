class CreateProviderMedicalConditions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_medical_conditions, id: false do |t|
      t.primary_key    :provider_medical_condition_id
      t.references     :provider_attest
      t.string         :medical_condition
      t.string         :practice_ability
      t.string         :current_status
      t.text           :disclosure_question_disclosure_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_medical_conditions
  end
end

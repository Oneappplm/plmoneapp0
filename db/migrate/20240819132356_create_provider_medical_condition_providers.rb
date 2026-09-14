class CreateProviderMedicalConditionProviders < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_medical_condition_providers do |t|
      t.integer        :caqh_provider_medical_condition_provider_id
      t.string         :last_name
      t.string         :first_name
      t.string         :middle_name
      t.string         :degree
      t.text           :phone_number
      t.references     :provider_attest, index: false
      t.integer        :caqh_provider_attest_id
      t.references     :provider_medical_condition, index: false
      t.integer        :caqh_provider_medical_condition_id

      t.timestamps
    end

    add_index  :provider_medical_condition_providers, :provider_attest_id, :name => 'pmcp_pa_id'
    add_index  :provider_medical_condition_providers, :provider_medical_condition_id, :name => 'pmcp_pmc_id'
  end

  def self.down
    drop_table :provider_medical_condition_providers
  end
end

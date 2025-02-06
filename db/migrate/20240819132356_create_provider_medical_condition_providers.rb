class CreateProviderMedicalConditionProviders < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_medical_condition_providers, primary_key: [:provider_attest_id,:provider_medical_condition_provider_id,:provider_medical_condition_id] do |t|
      t.integer        :provider_medical_condition_provider_id
      t.string         :last_name
      t.string         :first_name
      t.string         :middle_name
      t.string         :degree
      t.text           :phone_number
      t.integer        :provider_attest_id
      t.integer        :provider_medical_condition_id

      t.timestamps
    end

    add_index  :provider_medical_condition_providers, :provider_attest_id, :name => 'pmcp_pa_id'
    add_index  :provider_medical_condition_providers, :provider_medical_condition_id, :name => 'pmcp_pmc_id'
  end

  def self.down
    drop_table :provider_medical_condition_providers
  end
end

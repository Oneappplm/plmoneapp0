class CreateProviderDeas < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_deas do |t|
      t.integer        :caqh_provider_deaid
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :dea_number
      t.string         :state
      t.datetime       :expiration_date
      t.boolean        :dea_license_limitation_flag
      t.text           :dea_license_limitation_explanation
      t.text           :no_dea_explanation
      t.datetime       :application_date

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_deas
  end
end

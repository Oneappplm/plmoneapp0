class CreateProviderMedicalLicenses < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_medical_licenses do |t|
      t.integer        :caqh_provider_license_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :license_number
      t.string         :state
      t.boolean        :currently_practicing_flag
      t.datetime       :expiration_date
      t.string         :license_type
      t.datetime       :issue_date
      t.boolean        :license_unlimited_flag
      t.text           :license_limitation_explanation
      t.string         :sponsor_name
      t.datetime       :relinquish_date
      t.text           :relinquish_explanation
      t.text           :license_status_license_status_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_medical_licenses
  end
end

class CreateProviderCdsLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_cds_licenses do |t|
      t.references :provider
      t.string :cds_license_number
      t.string :no_cds_license
      t.integer :state_id
      t.datetime :cds_license_issue_date
      t.datetime :cds_license_expiration_date
      t.datetime :cds_renewal_effective_date

      t.timestamps
    end
  end
end

class CreateProviderDeaLicenses < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_dea_licenses do |t|
      t.references :provider
      t.string :dea_license_number
      t.integer :state_id
      t.datetime :dea_license_effective_date
      t.datetime :dea_license_expiration_date

      t.timestamps
    end
  end

  def down
    drop_table :provider_dea_licenses
  end
end

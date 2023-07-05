class CreateProviderCnpLicenses < ActiveRecord::Migration[7.0]
  def up
    create_table :provider_cnp_licenses do |t|
      t.references :provider
      t.string :cnp_license_number
      t.datetime :effective_date
      t.datetime :expiration_date

      t.timestamps
    end
  end

  def down
    drop_table :provider_cnp_licenses
  end
end

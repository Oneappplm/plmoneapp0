class CreateProviderMnLicenses < ActiveRecord::Migration[7.0]
  # created this table in the case this will be multilple in the future
  def change
    create_table :provider_mn_licenses do |t|
      t.references :provider
      t.string :mn_license_number
      t.datetime :mn_license_expiration_date

      t.timestamps
    end
  end
end

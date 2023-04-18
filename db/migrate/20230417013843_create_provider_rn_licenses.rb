class CreateProviderRnLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_rn_licenses do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :rn_license_number
      t.date :rn_license_effective_date
      t.date :rn_license_expiration_date

      t.timestamps
    end
  end
end

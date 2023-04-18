class CreateProviderNpLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_np_licenses do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :np_license_number
      t.date :np_license_effective_date
      t.date :np_license_expiration_date

      t.timestamps
    end
  end
end

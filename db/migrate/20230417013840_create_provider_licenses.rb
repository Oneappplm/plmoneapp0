class CreateProviderLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_licenses do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :license_number
      t.date :license_effective_date
      t.date :license_expiration_date

      t.timestamps
    end
  end
end

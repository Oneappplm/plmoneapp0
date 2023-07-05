class CreateProviderPaLicense < ActiveRecord::Migration[7.0]
  # created this table in the case this will be multilple in the future
  def up
    create_table :provider_pa_licenses do |t|
      t.references :provider
      t.string :pa_license_number
      t.datetime :pa_license_effective_date
      t.datetime :pa_license_expiration_date

      t.timestamps
    end
  end

  def down
    drop_table :provider_pa_licenses
  end
end

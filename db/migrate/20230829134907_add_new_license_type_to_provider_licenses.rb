class AddNewLicenseTypeToProviderLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_licenses, :license_type, :string
  end
end

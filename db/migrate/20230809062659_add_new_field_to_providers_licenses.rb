class AddNewFieldToProvidersLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_licenses, :license_state_renewal_date, :string
    add_column :provider_licenses, :no_state_license, :string
  end
end

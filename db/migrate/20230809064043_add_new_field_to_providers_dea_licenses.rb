class AddNewFieldToProvidersDeaLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_dea_licenses, :no_dea_license, :string
  end
end

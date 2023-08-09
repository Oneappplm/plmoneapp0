class AddNewFieldToProvidersRnLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_rn_licenses, :no_rn_license, :string
  end
end

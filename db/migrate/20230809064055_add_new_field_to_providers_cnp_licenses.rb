class AddNewFieldToProvidersCnpLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_cnp_licenses, :no_cnp_license, :string
  end
end

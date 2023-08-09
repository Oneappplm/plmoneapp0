class AddNewFieldToProvidersNpLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_np_licenses, :no_np_license, :string
  end
end

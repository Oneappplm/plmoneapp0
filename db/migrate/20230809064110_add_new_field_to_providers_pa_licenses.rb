class AddNewFieldToProvidersPaLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_pa_licenses, :no_pa_license, :string
  end
end

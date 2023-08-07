class AddNewColumnToProvidersDeaLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_dea_licenses, :dea_license_renewal_effective_date, :string
  end
end

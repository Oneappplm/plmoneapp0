class AddNewColumnToProvidersRnLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_rn_licenses, :rn_license_renewal_effective_date, :string
  end
end

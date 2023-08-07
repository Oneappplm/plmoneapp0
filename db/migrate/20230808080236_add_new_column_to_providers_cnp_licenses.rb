class AddNewColumnToProvidersCnpLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_cnp_licenses, :cnp_license_renewal_effective_date, :datetime
  end
end

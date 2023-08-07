class AddNewColumnToProvidersNpLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_np_licenses, :np_license_renewal_effective_date, :datetime
  end
end

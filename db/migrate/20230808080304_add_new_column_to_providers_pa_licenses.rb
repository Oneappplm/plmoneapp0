class AddNewColumnToProvidersPaLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_pa_licenses, :pa_license_renewal_effective_date, :datetime
  end
end

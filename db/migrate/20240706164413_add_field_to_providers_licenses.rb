class AddFieldToProvidersLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_licenses, :license_state_renewal_date, :date
  end
end

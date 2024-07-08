class RemoveFieldToProvidersLicenses < ActiveRecord::Migration[7.0]
  def change
    remove_column :provider_licenses, :license_state_renewal_date, :string
  end
end

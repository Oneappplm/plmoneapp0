class AddNewStateFieldToPaLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_pa_licenses, :state_id, :integer
  end
end

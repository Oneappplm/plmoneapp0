class AddNewStateFieldToRnLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_rn_licenses, :state_id, :integer
  end
end

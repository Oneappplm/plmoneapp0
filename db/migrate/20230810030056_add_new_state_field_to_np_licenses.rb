class AddNewStateFieldToNpLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_np_licenses, :state_id, :integer
  end
end

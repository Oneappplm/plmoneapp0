class AddNewStateFieldToAprnLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_cnp_licenses, :state_id, :integer
  end
end

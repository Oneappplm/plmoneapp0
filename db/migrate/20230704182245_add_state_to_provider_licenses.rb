class AddStateToProviderLicenses < ActiveRecord::Migration[7.0]
  def up
    add_column :provider_licenses, :state_id, :integer
  end

  def down
    remove_column :provider_licenses, :state_id, :integer
  end
end

class AddLicenseSearchUrlToStates < ActiveRecord::Migration[7.0]
  def change
    add_column :states, :license_search_url, :string
  end
end

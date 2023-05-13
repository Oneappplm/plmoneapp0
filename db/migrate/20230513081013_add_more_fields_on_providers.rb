class AddMoreFieldsOnProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :facility_location, :string
    add_column :providers, :facility_name, :string
    add_column :providers, :admitting_facility_address_line1, :string
    add_column :providers, :admitting_facility_address_line2, :string
    add_column :providers, :admitting_facility_city, :string
    add_column :providers, :admitting_facility_zip_code, :string
    add_column :providers, :admitting_facility_arrangments, :string
  end
end

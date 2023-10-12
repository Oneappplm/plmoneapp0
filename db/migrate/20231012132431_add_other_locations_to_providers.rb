class AddOtherLocationsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :primary_location, :string
  end
end

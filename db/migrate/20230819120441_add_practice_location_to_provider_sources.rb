class AddPracticeLocationToProviderSources < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_sources, :practice_location_id, :integer
  end
end

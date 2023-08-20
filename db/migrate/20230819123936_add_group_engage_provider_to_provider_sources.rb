class AddGroupEngageProviderToProviderSources < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_sources, :group_engage_provider_id, :integer
  end
end

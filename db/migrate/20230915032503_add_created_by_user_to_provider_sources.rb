class AddCreatedByUserToProviderSources < ActiveRecord::Migration[7.0]
  def change
    # the user who created the provider source(enrolled the provider in provider engage pages)
    add_column :provider_sources, :created_by_user, :integer
  end
end

class AddShowOnTicklerToProviderCds < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_cds, :show_on_tickler, :boolean
  end
end

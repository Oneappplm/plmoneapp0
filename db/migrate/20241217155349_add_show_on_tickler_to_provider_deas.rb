class AddShowOnTicklerToProviderDeas < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_deas, :show_on_tickler, :string
  end
end

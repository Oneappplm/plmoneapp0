class AddDcosToProviderTable < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :dcos, :string, default: false
  end
end

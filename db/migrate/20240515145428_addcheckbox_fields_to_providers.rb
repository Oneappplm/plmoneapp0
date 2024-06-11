class AddcheckboxFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :rcm_only, :boolean, default: false
  end
end
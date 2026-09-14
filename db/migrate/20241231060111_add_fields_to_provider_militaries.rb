class AddFieldsToProviderMilitaries < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_militaries, :type_of_discharge, :string
    add_column :provider_militaries, :reserve_separation_month, :string
    add_column :provider_militaries, :reserve_separation_year, :string
    add_column :provider_militaries, :currently_active_reserve, :boolean
  end
end

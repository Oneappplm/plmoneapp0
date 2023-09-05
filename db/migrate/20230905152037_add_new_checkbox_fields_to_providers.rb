class AddNewCheckboxFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :dea_not_applicable, :string
    add_column :providers, :cds_not_applicable, :string
    add_column :providers, :rn_not_applicable, :string
    add_column :providers, :aprn_not_applicable, :string
    add_column :providers, :state_not_applicable, :string
    add_column :providers, :dea_explain, :string
    add_column :providers, :cds_explain, :string
    add_column :providers, :rn_explain, :string
    add_column :providers, :cnp_explain, :string
    add_column :providers, :license_explain, :string
  end
end

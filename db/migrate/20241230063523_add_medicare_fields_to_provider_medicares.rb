class AddMedicareFieldsToProviderMedicares < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_medicares, :issue_date, :date
    add_column :provider_medicares, :medicare_opt_in, :boolean
    add_column :provider_medicares, :medicare_opt_out, :boolean
    add_column :provider_medicares, :medicare_partial, :boolean
  end
end

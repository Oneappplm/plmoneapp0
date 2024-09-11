class AddColumnsToProviderMedicares < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_medicares, :provider_medicare_id, :integer if !column_exists?(:provider_medicares, :provider_medicare_id)
    add_column :provider_medicares, :provider_attest_id, :integer if !column_exists?(:provider_medicares, :provider_attest_id)
    add_column :provider_medicares, :medicare_number, :string if !column_exists?(:provider_medicares, :medicare_number)
    add_column :provider_medicares, :state, :string if !column_exists?(:provider_medicares, :state)
  end
end

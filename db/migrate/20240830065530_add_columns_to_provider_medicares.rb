class AddColumnsToProviderMedicares < ActiveRecord::Migration[7.0]
  def change
   add_column :provider_medicares, :caqh_provider_medicare_id, :integer
   add_column :provider_medicares, :provider_attest_id, :integer
   add_column :provider_medicares, :caqh_provider_attest_id, :integer
   add_column :provider_medicares, :medicare_number, :string
   add_column :provider_medicares, :state, :string
  end
end

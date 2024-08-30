class AddColumnsToProviderMedicaids < ActiveRecord::Migration[7.0]
  def change
   add_column :provider_medicaids, :provider_medicaid_id, :integer
   add_column :provider_medicaids, :provider_attest_id, :integer
   add_column :provider_medicaids, :medicaid_number, :string
   add_column :provider_medicaids, :state, :string
  end
end

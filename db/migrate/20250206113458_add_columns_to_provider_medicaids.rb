class AddColumnsToProviderMedicaids < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_medicaids, :provider_medicaid_id, :integer if !column_exists?(:provider_medicaids, :provider_medicaid_id)
    add_column :provider_medicaids, :provider_attest_id, :integer if !column_exists?(:provider_medicaids, :provider_attest_id)
    add_column :provider_medicaids, :medicaid_number, :string if !column_exists?(:provider_medicaids, :medicaid_number)
    add_column :provider_medicaids, :state, :string if !column_exists?(:provider_medicaids, :state)
  end
end

class AddClaimsHistoryAuditToProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_insurance_coverages, :claims_history_audit, :string
  end
end

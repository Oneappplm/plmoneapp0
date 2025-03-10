class AddAuditStatusToProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_insurance_coverages, :audit_status, :string
  end
end

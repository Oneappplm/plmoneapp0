class AddAuditStatusToProviderLicensures < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_licensures, :audit_status, :string
  end
end

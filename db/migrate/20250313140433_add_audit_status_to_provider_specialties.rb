class AddAuditStatusToProviderSpecialties < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_specialties, :audit_status, :string
  end
end

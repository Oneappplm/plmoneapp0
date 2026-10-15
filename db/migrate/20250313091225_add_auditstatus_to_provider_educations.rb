class AddAuditstatusToProviderEducations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_educations, :audit_status, :string
  end
end

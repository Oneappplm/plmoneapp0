class AddAuditStatusNameToProviderEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_employments, :audit_status, :string
  end
end

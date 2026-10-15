class AddAuditStatusToCertifications < ActiveRecord::Migration[7.0]
  def change
    add_column :certifications, :audit_status, :string
  end
end

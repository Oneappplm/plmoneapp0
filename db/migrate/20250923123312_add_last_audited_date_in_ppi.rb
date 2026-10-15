class AddLastAuditedDateInPpi < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :latest_audit_completed_date, :date
  end
end

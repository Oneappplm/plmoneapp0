class AddAuditStatusToPeerTable < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_information_peer_refs, :audit_status, :string
  end
end

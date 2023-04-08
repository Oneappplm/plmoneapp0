class AddMoreFieldsToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :title, :string
    add_column :clients, :prefix, :string
    add_column :clients, :suffix, :string
    add_column :clients, :gender, :string
    add_column :clients, :prac_type, :string
    add_column :clients, :specialty_name, :string
    add_column :clients, :address1, :string
    add_column :clients, :address2, :string
    add_column :clients, :state_or_province, :string
    add_column :clients, :country, :string
    add_column :clients, :postal_code, :string
    add_column :clients, :primary_phone, :string
    add_column :clients, :primary_email, :string
    add_column :clients, :client_specified_id, :string
    add_column :clients, :practitioner_guid, :string
    add_column :clients, :client_guid, :string
    add_column :clients, :file_path, :string
    add_column :clients, :signature_date, :string
    add_column :clients, :file_status, :string
    add_column :clients, :app_receive_date, :string
    add_column :clients, :app_receive_complete_date, :string
    add_column :clients, :app_complete_date, :string
    add_column :clients, :approval_date, :string
    add_column :clients, :cred_or_recred, :string
    add_column :clients, :org_type, :string
    add_column :clients, :caqhid, :string
    add_column :clients, :import_exid, :string
    add_column :clients, :client_id, :string
    add_column :clients, :external_id, :string
  end
end

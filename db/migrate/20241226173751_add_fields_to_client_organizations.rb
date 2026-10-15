class AddFieldsToClientOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :client_organizations, :primary_service, :string
    add_column :client_organizations, :tin_number, :string
    add_column :client_organizations, :tin_name, :string
    add_column :client_organizations, :organization_facility_type, :string
    add_column :client_organizations, :credential, :integer, default: 0, null: false
    add_column :client_organizations, :recredential, :integer, default: 0, null: false
    add_column :client_organizations, :contact_method, :string
    add_column :client_organizations, :contact_first_name, :string
    add_column :client_organizations, :contact_middle_name, :string
    add_column :client_organizations, :contact_last_name, :string
    add_column :client_organizations, :contact_suffix, :string
    add_column :client_organizations, :email_address, :string
    add_column :client_organizations, :mail_stop, :string
    add_column :client_organizations, :organization_country, :string
    add_column :client_organizations, :client_due_date, :date
    add_column :client_organizations, :client_batch_date, :date
    add_column :client_organizations, :client_batch_name, :string
    add_column :client_organizations, :client_batch_id, :string
  end
end

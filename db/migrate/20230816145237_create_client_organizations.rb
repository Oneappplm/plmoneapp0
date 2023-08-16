class CreateClientOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :client_organizations do |t|
      t.string :organization_name
      t.string :organization_type
      t.string :organization_npi
      t.string :organization_address_1
      t.string :organization_address_2
      t.string :organization_city
      t.integer :organization_state_id
      t.string :organization_zipcode
      t.string :organization_phone_number
      t.string :organization_fax_number
      t.string :organization_dba_name
      t.string :organization_tax_id      
      t.timestamps
    end
  end
end

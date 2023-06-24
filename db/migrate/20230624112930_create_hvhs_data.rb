class CreateHvhsData < ActiveRecord::Migration[7.0]
  def change
    create_table :hvhs_data do |t|
      t.string :npi
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :degree_titles
      t.string :office_address_line1
      t.string :office_address_line2
      t.string :office_city
      t.string :office_state
      t.string :office_zip_code
      t.string :phone_number
      t.string :practice_email_address
      t.string :office_mgr_email
      t.string :office_mgr_fax
      t.string :office_mgr_first_name
      t.string :office_mgr_last_name
      t.string :office_mgr_phone
      t.string :special_type
      t.string :taxonomy_code
      t.string :license_number
      t.string :license_state

      t.timestamps
    end
  end
end

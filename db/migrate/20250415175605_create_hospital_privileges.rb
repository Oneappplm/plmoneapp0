class CreateHospitalPrivileges < ActiveRecord::Migration[7.0]
  def change
    create_table :hospital_privileges do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.string :state_abbr
      t.string :hp_facility_name
      t.boolean :hp_no_longer_in_business
      t.string :hp_mso_address_line1
      t.string :hp_mso_address_line2
      t.string :hp_city
      t.string :hp_zipcode
      t.string :hp_mso_telephone_number
      t.string :hp_ext
      t.string :hp_mso_fax_number
      t.string :hp_mso_email_address
      t.string :hp_department_name
      t.string :hp_division_name
      t.string :director_first_name
      t.string :director_last_name
      t.string :unrestricted_privileges
      t.string :privileges_temporary
      t.string :privilege_status

      t.timestamps
    end
  end
end

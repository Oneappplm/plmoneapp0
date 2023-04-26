class CreateEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_groups do |t|
      t.string :group_name
      t.string :group_code
      t.string :office_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :phone_number
      t.string :ext
      t.string :fax_number
      t.string :business_group, default: 'no'
      t.string :legal_business_name
      t.string :another_business_name, default: 'no'
      t.string :other_business_name
      t.string :other_business_type
      t.string :specify_type_of_group
      t.string :shared_tin, default: 'no'
      t.string :tin_file
      t.string :specify_type_of_group_file
      t.string :npi_digit_type
      t.string :npi_digit_type_group
      t.string :provider_type
      t.string :po_box
      t.string :po_box_city
      t.string :po_box_state
      t.string :po_box_zip_code
      t.string :ca_po_box_address
      t.string :ca_po_box_city
      t.string :ca_po_box_state
      t.string :ca_po_box_zip_code
      t.string :individual_ownership

      t.timestamps
    end
  end
end

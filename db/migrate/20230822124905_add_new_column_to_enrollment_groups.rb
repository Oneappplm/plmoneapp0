class AddNewColumnToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :telehealth_providers, :string
    add_column :enrollment_groups, :admitting_privileges, :string
    add_column :enrollment_groups, :name_admitting_physician, :string
    add_column :enrollment_groups, :facility_location, :string
    add_column :enrollment_groups, :facility_name, :string
    add_column :enrollment_groups, :admitting_facility_address_line1, :string
    add_column :enrollment_groups, :admitting_facility_address_line2, :string
    add_column :enrollment_groups, :admitting_facility_city, :string
    add_column :enrollment_groups, :admitting_facility_state, :string
    add_column :enrollment_groups, :admitting_facility_zip_code, :string
    add_column :enrollment_groups, :admitting_facility_arrangments, :string
  end
end

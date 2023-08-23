class AddNewFieldsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :telehealth_providers, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_privileges, :string, if_not_exists: true
    add_column :enrollment_groups, :name_admitting_physician, :string, if_not_exists: true
    add_column :enrollment_groups, :facility_location, :string, if_not_exists: true
    add_column :enrollment_groups, :facility_name, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_facility_address_line1, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_facility_address_line2, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_facility_city, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_facility_state, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_facility_zip_code, :string, if_not_exists: true
    add_column :enrollment_groups, :admitting_facility_arrangments, :string, if_not_exists: true
  end
end

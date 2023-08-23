class CreateEnrollmentGroupSvcLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_group_svc_locations do |t|
      t.references :enrollment_group
      t.string :primary_service_non_office_area
      t.string :primary_service_location_apps
      t.string :primary_service_zip_code
      t.string :primary_service_office_email
      t.string :primary_service_fax
      t.string :primary_service_office_website
      t.string :primary_service_crisis_phone
      t.string :primary_service_location_other_phone
      t.string :primary_service_appt_scheduling
      t.string :primary_service_interpreter_language
      t.string :primary_service_telehealth_only_state
      t.timestamps
    end
  end
end

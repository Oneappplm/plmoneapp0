class AddNewFieldToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :telehealth_providers, :string
    add_column :providers, :admitting_facility_state, :string
    add_column :providers, :state_license_copy_file, :string
    add_column :providers, :dea_copy_file, :string
    add_column :providers, :w9_form_file, :string
    add_column :providers, :certificate_insurance_file, :string
    add_column :providers, :drivers_license_file, :string
    add_column :providers, :board_certification_file, :string
    add_column :providers, :caqh_app_copy_file, :string
    add_column :providers, :cv_file, :string
    add_column :providers, :telehealth_license_copy_file, :string
  end
end

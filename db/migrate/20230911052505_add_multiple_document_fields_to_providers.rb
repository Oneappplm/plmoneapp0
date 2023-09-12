class AddMultipleDocumentFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :state_license_copies, :json, if_not_exists: true
    add_column :providers, :dea_copies, :json, if_not_exists: true
    add_column :providers, :w9_form_copies, :json, if_not_exists: true
    add_column :providers, :certificate_insurance_copies, :json, if_not_exists: true
    add_column :providers, :driver_license_copies, :json, if_not_exists: true
    add_column :providers, :board_certification_copies, :json, if_not_exists: true
    add_column :providers, :caqh_app_copies, :json, if_not_exists: true
    add_column :providers, :cv_copies, :json, if_not_exists: true
    add_column :providers, :telehealth_license_copies, :json, if_not_exists: true
  end
end

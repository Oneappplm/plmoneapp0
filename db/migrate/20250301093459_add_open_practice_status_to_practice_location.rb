class AddOpenPracticeStatusToPracticeLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_locations, :open_practice_status, :string, array: true, default: []
    add_column :practice_locations, :ada_wrp_status, :string, array: true, default: []
    add_column :practice_locations, :disabled_other_services_wrp_status, :string, array: true, default: []
    add_column :practice_locations, :public_transportation_wrp_status, :string, array: true, default: []
    add_column :practice_locations, :laboratory_services_wrp_status, :string, array: true, default: []
    add_column :practice_locations, :radiology_services_xray_status, :string, array: true, default: []
    add_column :practice_locations, :anesthesia_administered_status, :string, array: true, default: []
  end
end

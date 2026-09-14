class AddHealthPlansFieldToPpi < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :hp_health_plans, :string, array: true, default: []
    add_column :provider_personal_informations, :hp_hospitals, :string, array: true, default: []
    add_column :provider_personal_informations, :hp_directories, :string, array: true, default: []
  end
end

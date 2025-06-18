class AddhealthlFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_informations do |t|
      # Healthcare Facilities Authorization (multi-select fields)
      t.text :hp_health_plans, array: true, default: []
      t.text :hp_hospitals, array: true, default: []
      t.text :hp_directories, array: true, default: []
    end
  end
end

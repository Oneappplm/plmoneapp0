class AddPopulationServedFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_informations do |t|
      # Population Served fields
      t.string :target_population_privileges
      t.string :populations_employment_type
      t.text   :populations_served, array: true, default: []
      t.string :specialty_student_intern
      t.text   :populations_infos
      t.text   :populations_served_other
    end
  end
end

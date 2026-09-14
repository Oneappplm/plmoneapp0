class AddMoreFieldsToProviderMilitaries < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_militaries do |t|
      t.string :caqh_id
      t.string :npi_number
      t.string :medicare_upin_number
      t.boolean :tricare_provider
      t.string :tricare_group_number
      t.boolean :certified_workers_comp_provider
      t.string :certificate_number
      t.boolean :certified_qualified_medical_examiner
      t.boolean :agreed_medical_examiner
      t.boolean :us_military_service
      t.string :branch_of_military
      t.text :comments
    end
  end
end

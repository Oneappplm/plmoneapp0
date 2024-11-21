class CreateProviderPersonalInformationReinstatements < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_reinstatements do |t|
      t.string :state
      t.string :general
      t.string :exclusion_type
      t.string :specialty
      t.datetime :process_date
      t.datetime :reinstatement_date
      t.references :provider_personal_information, index: false

      t.timestamps
    end

    add_index  :provider_personal_information_reinstatements, :provider_personal_information_id, :name => 'ppir_ppi_id'
  end
end

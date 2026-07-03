class CreateProviderPersonalInformationOfacs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_ofacs do |t|
      t.references :provider_personal_information, null: false, foreign_key: true, index: { name: "idx_ppi_ofac" }
      t.datetime :source_date
      t.datetime :verification_date
      t.string :search_result
      t.date :effective_date
      t.string :supporting_document

      t.timestamps
    end
  end
end

class CreateProviderPersonalInformationOmigs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_omigs do |t|
      t.references :provider_personal_information, null: false, foreign_key: true, index: { name: "idx_ppi_omig_ppi_id" }
      t.datetime :source_date
      t.datetime :verification_date
      t.string :search_result
      t.date :effective_date
      t.string :supporting_document

      t.timestamps
    end
  end
end

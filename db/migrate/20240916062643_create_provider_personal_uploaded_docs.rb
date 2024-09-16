class CreateProviderPersonalUploadedDocs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_uploaded_docs do |t|
      t.string :image_classification
      t.string :sub_section
      t.string :record_item
      t.text :description
      t.boolean :exclude_from_profile
      t.string :file_upload
      t.references :provider_attest, null: false, foreign_key: { to_table: :provider_attests, primary_key: :provider_attest_id }
      t.integer :provider_id

      t.timestamps
    end
  end
end

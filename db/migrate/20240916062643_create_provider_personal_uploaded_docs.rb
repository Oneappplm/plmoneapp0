class CreateProviderPersonalUploadedDocs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_uploaded_docs do |t|
      t.string :image_classification
      t.string :sub_section
      t.string :record_item
      t.text :description
      t.boolean :exclude_from_profile
      t.string :file_upload
      t.references :provider_attest
      t.integer    :caqh_provider_attest_id
      t.references :provider_personal_information, index: false
      t.integer :caqh_provider_id

      t.timestamps
    end

    add_index  :provider_personal_uploaded_docs, :provider_personal_information_id, :name => 'ppud_ppi_id'
  end
end

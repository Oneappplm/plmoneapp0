class CreateClinetUploadedDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :clinet_uploaded_documents do |t|
      t.string :image_classification
      t.string :sub_section
      t.string :record_item
      t.text :description
      t.boolean :exclude_from_profile
      t.string :file_upload

      t.timestamps
    end
  end
end

class CreateProviderSourceDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_documents do |t|
      t.references :provider_source, null: false, foreign_key: true
      t.string :file_name
      t.string :file_path

      t.timestamps
    end
  end
end

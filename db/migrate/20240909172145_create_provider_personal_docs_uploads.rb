class CreateProviderPersonalDocsUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_docs_uploads do |t|
      t.string :file_upload
      t.references :provider_attest, null: false, foreign_key: { to_table: :provider_attests, primary_key: :provider_attest_id }
      t.integer :provider_id

      t.timestamps
    end
  end
end

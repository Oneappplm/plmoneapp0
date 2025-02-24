class CreateProviderPersonalDocsUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_docs_uploads do |t|
      t.string :file_upload
      t.references :provider_attest
      t.integer    :caqh_provider_attest_id
      t.references :provider_personal_information, index: false
      t.integer :caqh_provider_id

      t.timestamps
    end
    add_index  :provider_personal_docs_uploads, :provider_personal_information_id, :name => 'ppdu_ppi_id'

  end
end
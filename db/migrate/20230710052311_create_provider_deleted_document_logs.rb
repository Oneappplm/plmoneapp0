class CreateProviderDeletedDocumentLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_deleted_document_logs do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :document_key
      t.string :title
      t.string :note
      t.string :deleted_by
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

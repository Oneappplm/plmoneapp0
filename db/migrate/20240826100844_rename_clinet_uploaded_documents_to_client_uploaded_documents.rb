class RenameClinetUploadedDocumentsToClientUploadedDocuments < ActiveRecord::Migration[7.0]
  def change
    rename_table :clinet_uploaded_documents, :client_uploaded_documents
  end
end

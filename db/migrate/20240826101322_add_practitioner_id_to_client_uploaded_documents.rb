class AddPractitionerIdToClientUploadedDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :client_uploaded_documents, :practitioner_id, :integer
  end
end

class AddFileToDeaImportUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :dea_import_uploads, :file, :string
  end
end

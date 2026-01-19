class AddS3KeyToDeaImportUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :dea_import_uploads, :s3_key, :string
    add_column :dea_import_uploads, :original_filename, :string
    add_column :dea_import_uploads, :byte_size, :bigint
    add_index  :dea_import_uploads, :s3_key
  end
end

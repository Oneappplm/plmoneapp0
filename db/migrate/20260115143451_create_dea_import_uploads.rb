class CreateDeaImportUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :dea_import_uploads do |t|

      t.timestamps
    end
  end
end

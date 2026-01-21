class CreateNpdbWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :npdb_webcrawler_logs do |t|
      t.references :provider_npdb, null: false, foreign_key: true
      t.references :rva_information, null: false, foreign_key: true
      t.string :filepath
      t.string :status
      t.string :filetype

      t.timestamps
    end
  end
end

class CreateOigWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :oig_webcrawler_logs do |t|
      t.string :filepath
      t.string :filetype
      t.string :status
      t.references :rva_information, null: false, foreign_key: true

      t.timestamps
    end
  end
end

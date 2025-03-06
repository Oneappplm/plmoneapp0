class CreateDeaWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :dea_webcrawler_logs do |t|
      t.string :filetype
      t.string :filepath
      t.string :status
      t.references :rva_information, null: false, foreign_key: true

      t.timestamps
    end
  end
end

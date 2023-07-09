class CreateWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :webcrawler_logs do |t|
      t.string :crawler_type
      t.string :filepath
      t.string :filetype
      t.string :status

      t.timestamps
    end
  end
end

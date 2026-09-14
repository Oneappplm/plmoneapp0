class CreateNpiWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :npi_webcrawler_logs do |t|
      t.string :npi_number
      t.string :filepath
      t.string :filetype
      t.string :status
      t.references :provider_personal_information, foreign_key: true
      t.timestamps
    end
  end
end

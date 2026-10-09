class AddHtmlFilepathToDeaWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :dea_webcrawler_logs, :html_filepath, :string
  end
end

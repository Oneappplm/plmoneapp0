class AddReportPayloadToDeaWebcrawlerLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :dea_webcrawler_logs, :report_payload, :jsonb, default: {}, null: false
  end
end

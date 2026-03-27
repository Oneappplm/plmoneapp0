class AddUpdatedByToEpdLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :epd_logs, :updated_by, :string
    add_column :epd_logs, :source, :string
  end
end

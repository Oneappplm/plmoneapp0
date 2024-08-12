class AddColumnToAppTracker < ActiveRecord::Migration[7.0]
  def change
    add_column :app_trackers, :file_status, :string
    add_column :app_trackers, :comments, :text
    add_column :app_trackers, :master_review_list, :string
    add_column :app_trackers, :master_issue_list, :string
    add_column :app_trackers, :expedite, :boolean
    add_column :app_trackers, :issue, :string
    add_column :app_trackers, :review, :string
  end
end

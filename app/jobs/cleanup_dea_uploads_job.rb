# app/jobs/cleanup_dea_uploads_job.rb
class CleanupDeaUploadsJob < ApplicationJob
  queue_as :default

  def perform(days: 2)
    cutoff = Time.current - days.days

    DeaImportUpload.where("created_at < ?", cutoff).find_each do |u|
      u.file.purge_later if u.file.attached?
      u.destroy!
    end
  end
end

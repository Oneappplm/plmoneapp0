# app/controllers/mhc/dea_files_controller.rb
class Mhc::DeaFilesController < ApplicationController
  DEA_TMP_DIR = Rails.root.join("tmp", "dea_uploads")

  def new; end

  def create
    if params[:dea_file].blank?
      redirect_to new_mhc_dea_file_path, alert: "Please select a file."
      return
    end

    # Store upload in ActiveStorage (works on Hatchbox/Sidekiq)
    upload = DeaImportUpload.create!(
      file: params[:dea_file]
    )

    file_path = upload.file.path
    raise "File not saved" unless file_path && File.exist?(file_path)

    # Enqueue background job using blob signed_id (NOT tmp path)
    job = WeeklyDeaImportJob.perform_later(upload.id)

    # Create progress entry immediately so UI doesn't show "not_found"
    begin
      key = "dea_import:#{job.job_id}"
      $redis.multi do |r|
        r.hset(key, "status", "queued")
        r.hset(key, "processed", 0)
        r.hset(key, "total", 0)
        r.hset(key, "last_update", Time.current.to_i)
        r.expire(key, REDIS_TTL_SECONDS)
      end
    rescue => e
      Rails.logger.warn("Redis progress init failed for job #{job.job_id}: #{e.class} #{e.message}")
    end

    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end

  private

  def cleanup_old_files!(dir, older_than:)
    Dir.glob(dir.join("dea_*")).each do |path|
      begin
        File.delete(path) if File.file?(path) && File.mtime(path) < Time.current - older_than
      rescue => e
        Rails.logger.warn("DEA cleanup failed for #{path}: #{e.message}")
      end
    end
  end
end

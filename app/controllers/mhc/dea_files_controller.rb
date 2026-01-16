class Mhc::DeaFilesController < ApplicationController
  REDIS_TTL_SECONDS = 6.hours.to_i

  def new; end

  def create
    if params[:dea_file].blank?
      redirect_to new_mhc_dea_file_path, alert: "Please select a file."
      return
    end

    upload = DeaImportUpload.create!(file: params[:dea_file])

    file_path = upload.file.path
    unless file_path.present? && File.exist?(file_path)
      redirect_to new_mhc_dea_file_path, alert: "File not saved properly."
      return
    end

    job = WeeklyDeaImportJob.perform_later(upload.id)

    # Create progress immediately so UI doesn't show not_found
    key = "dea_import:#{job.job_id}"
    begin
      $redis.multi do |r|
        r.hset(key, "status", "queued")
        r.hset(key, "processed", 0)
        r.hset(key, "total", 0)
        r.hset(key, "last_update", Time.current.to_i)
        r.expire(key, REDIS_TTL_SECONDS)
      end
    rescue => e
      Rails.logger.warn("Redis init failed: #{e.message}")
    end

    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end
end

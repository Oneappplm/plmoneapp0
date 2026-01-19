# app/controllers/mhc/dea_files_controller.rb
class Mhc::DeaFilesController < ApplicationController
  REDIS_TTL_SECONDS = 24.hours.to_i

  def new; end

  def create
    # ✅ JSON direct-to-S3 flow
    if request.format.json? || request.content_type&.include?("application/json")
      key = params[:key].presence
      return render json: { success: false, message: "Missing S3 key." }, status: 422 if key.blank?

      upload = DeaImportUpload.create!(
        s3_key:            key,
        original_filename: params[:filename].to_s,
        byte_size:         params[:byte_size].to_i
      )

      job = WeeklyDeaImportJob.set(queue: :dea_import).perform_later(upload.id)

      init_progress!(job.job_id, upload.byte_size)

      return render json: { success: true, job_id: job.job_id }
    end

    # ✅ Old multipart flow (local / small file)
    if params[:dea_file].blank?
      redirect_to new_mhc_dea_file_path, alert: "Please select a file."
      return
    end

    upload = DeaImportUpload.create!(file: params[:dea_file])
    job = WeeklyDeaImportJob.set(queue: :dea_import).perform_later(upload.id)

    init_progress!(job.job_id, upload.file.size)

    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end

  private

  def init_progress!(job_id, total_bytes)
    key = "dea_import:#{job_id}"
    $redis.multi do |r|
      r.hset(key, "status", "queued")
      r.hset(key, "processed", 0)
      r.hset(key, "total", 0) # line-count unknown initially
      r.hset(key, "bytes_read", 0)
      r.hset(key, "total_bytes", total_bytes.to_i)
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
  rescue => e
    Rails.logger.warn("Redis init failed: #{e.class} #{e.message}")
  end
end

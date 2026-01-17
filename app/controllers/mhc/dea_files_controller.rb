class Mhc::DeaFilesController < ApplicationController
  REDIS_TTL_SECONDS = 6.hours.to_i

  def new; end

  def create
    # Case A: Direct-to-S3 JSON trigger
    if params[:key].present?
      return start_import_from_s3_key!
    end

    # Case B: Normal multipart upload (fallback for local/dev)
    if params[:dea_file].present?
      return start_import_from_uploaded_file!
    end

    render json: { success: false, message: "Missing S3 key." }, status: :unprocessable_entity
  end

  private

  def start_import_from_s3_key!
    key       = params[:key].to_s
    filename  = params[:filename].to_s
    byte_size = params[:byte_size].to_i

    upload = DeaImportUpload.create!(file: key)
    job = WeeklyDeaImportJob.perform_later(upload.id)

    init_progress(job.job_id, byte_size)

    render json: { success: true, job_id: job.job_id }
  end

  def start_import_from_uploaded_file!
    uploaded_file = params[:dea_file]

    # Save locally (small file dev fallback)
    dir = Rails.root.join("tmp", "dea_uploads")
    FileUtils.mkdir_p(dir)

    tmp_path = dir.join("dea_#{Time.current.to_i}_#{uploaded_file.original_filename}")
    File.binwrite(tmp_path, uploaded_file.read)

    # Store local path in file column just for local/dev mode
    upload = DeaImportUpload.create!(file: tmp_path.to_s)
    job = WeeklyDeaImportJob.perform_later(upload.id)

    init_progress(job.job_id, File.size(tmp_path))

    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end

  def init_progress(job_id, byte_size)
    redis_key = "dea_import:#{job_id}"
    $redis.multi do |r|
      r.hset(redis_key, "status", "queued")
      r.hset(redis_key, "processed", 0)
      r.hset(redis_key, "total", 0)
      r.hset(redis_key, "bytes_read", 0)
      r.hset(redis_key, "total_bytes", byte_size.to_i)
      r.hset(redis_key, "last_update", Time.current.to_i)
      r.expire(redis_key, REDIS_TTL_SECONDS)
    end
  end
end

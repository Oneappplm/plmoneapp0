class Mhc::DeaFilesController < ApplicationController
  REDIS_TTL_SECONDS = 24.hours.to_i

  # If your ApplicationController tracks every request, skip it for this JSON endpoint
  skip_after_action :track_event, only: [:create], raise: false

  def new; end

  def create
    if json_request?
      return create_from_s3_key!
    end

    return create_from_uploaded_file! if params[:dea_file].present?

    render json: { success: false, message: "Missing S3 key." }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[DEA CREATE] validation failed: #{e.record.errors.full_messages.join(', ')}")
    render json: { success: false, message: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("[DEA CREATE] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(20).join("\n"))
    render json: { success: false, message: e.message }, status: :internal_server_error
  end

  private

  def json_request?
    request.format.json? || request.content_type.to_s.include?("application/json")
  end

  def create_from_s3_key!
    key       = params[:key].to_s.presence
    filename  = params[:filename].to_s
    byte_size = params[:byte_size].to_i

    if key.blank?
      render json: { success: false, message: "Missing S3 key." }, status: :unprocessable_entity
      return
    end

    upload = DeaImportUpload.create!(
      s3_key: key,
      original_filename: filename,
      byte_size: byte_size
    )

    job = WeeklyDeaImportJob.set(queue: :dea_import).perform_later(upload.id)
    init_progress!(job.job_id, byte_size)

    render json: { success: true, job_id: job.job_id }, status: :ok
  end

  def create_from_uploaded_file!
    upload = DeaImportUpload.create!(file: params[:dea_file])

    size =
      if upload.file.respond_to?(:size)
        upload.file.size.to_i
      elsif upload.file.path.present? && File.exist?(upload.file.path)
        File.size(upload.file.path)
      else
        0
      end

    job = WeeklyDeaImportJob.set(queue: :dea_import).perform_later(upload.id)
    init_progress!(job.job_id, size)

    redirect_to new_mhc_dea_file_path(job_id: job.job_id), notice: "DEA import started."
  end

  def init_progress!(job_id, total_bytes)
    key = "dea_import:#{job_id}"
    $redis.multi do |r|
      r.hset(key, "status", "queued")
      r.hset(key, "processed", 0)
      r.hset(key, "total", 0)
      r.hset(key, "bytes_read", 0)
      r.hset(key, "total_bytes", total_bytes.to_i)
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
  end
end

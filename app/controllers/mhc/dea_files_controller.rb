class Mhc::DeaFilesController < ApplicationController
  REDIS_TTL_SECONDS = 24.hours.to_i

  skip_after_action :track_event, only: [:create, :start_import], raise: false

  def new; end

  # local / small file fallback
  def create
    unless params[:dea_file].present?
      redirect_to new_mhc_dea_file_path, alert: "Please select a file."
      return
    end

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
  rescue => e
    Rails.logger.error("[DEA CREATE] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(20).join("\n"))
    redirect_to new_mhc_dea_file_path, alert: e.message
  end

  # production / S3 direct-upload flow
  def start_import
    Rails.logger.info("[DEA START_IMPORT] HIT content_type=#{request.content_type} params=#{params.to_unsafe_h.except('authenticity_token').inspect}")

    key = params[:key].to_s.presence
    filename = params[:filename].to_s
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
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[DEA START_IMPORT] validation failed: #{e.record.errors.full_messages.join(', ')}")
    render json: { success: false, message: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("[DEA START_IMPORT] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(20).join("\n"))
    render json: { success: false, message: e.message }, status: :internal_server_error
  end

  private

  def init_progress!(job_id, total_bytes = 0)
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

class Mhc::DeaFilesController < ApplicationController
  REDIS_TTL_SECONDS = 24.hours.to_i

  skip_after_action :track_event, only: [:create], raise: false

  def new; end

  def create
    Rails.logger.info("[DEA CREATE] params=#{params.to_unsafe_h.except('authenticity_token').inspect}")

    # S3 flow
    if params[:key].present?
      upload = DeaImportUpload.create!(
        s3_key: params[:key],
        original_filename: params[:filename],
        byte_size: params[:byte_size].to_i
      )

      job = WeeklyDeaImportJob.set(queue: :dea_import).perform_later(upload.id)
      init_progress!(job.job_id, params[:byte_size].to_i)

      render json: { success: true, job_id: job.job_id }, status: :ok
      return
    end

    # local fallback
    if params[:dea_file].present?
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
      return
    end

    render json: { success: false, message: "Missing file or S3 key." }, status: :unprocessable_entity

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[DEA CREATE] validation failed: #{e.record.errors.full_messages.join(', ')}")
    render json: { success: false, message: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity

  rescue => e
    Rails.logger.error("[DEA CREATE] #{e.class}: #{e.message}")
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

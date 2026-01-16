# app/controllers/mhc/dea_import_progress_controller.rb
class Mhc::DeaImportProgressController < ApplicationController
  def show
    job_id = params[:job_id]
    redis  = $redis
    key    = "dea_import:#{job_id}"

    progress = redis.hgetall(key)
    return render json: { status: "not_found" } if progress.blank?

    status      = progress["status"]
    processed   = progress["processed"]&.to_i || 0
    total       = progress["total"]&.to_i || 0
    last_ping   = progress["last_update"]&.to_i || 0
    bytes_read  = progress["bytes_read"]&.to_i || 0
    total_bytes = progress["total_bytes"]&.to_i || 0

    # Sidekiq stopped / stuck (no heartbeat)
    if last_ping > 0 && (Time.now.to_i - last_ping > 10) && status == "running"
      return render json: {
        status: "stopped",
        processed: processed,
        total: total,
        bytes_read: bytes_read,
        total_bytes: total_bytes
      }
    end

    # failed
    if status == "failed"
      return render json: {
        status: "failed",
        processed: processed,
        total: total,
        bytes_read: bytes_read,
        total_bytes: total_bytes,
        error: progress["error"]
      }
    end

    # finished
    if status == "finished"
      return render json: {
        status: "finished",
        processed: processed,
        total: total,
        bytes_read: bytes_read,
        total_bytes: total_bytes
      }
    end

    # queued / running
    render json: {
      status: status.presence || "working",
      processed: processed,
      total: total,
      bytes_read: bytes_read,
      total_bytes: total_bytes
    }
  end
end

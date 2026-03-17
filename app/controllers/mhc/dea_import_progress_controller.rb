# app/controllers/mhc/dea_import_progress_controller.rb
class Mhc::DeaImportProgressController < ApplicationController
  def show
    job_id = params[:job_id]
    key    = "dea_import:#{job_id}"

    progress = $redis.hgetall(key)
    return render json: { status: "not_found" } if progress.blank?

    status      = progress["status"]
    processed   = progress["processed"].to_i
    total       = progress["total"].to_i
    bytes_read  = progress["bytes_read"].to_i
    total_bytes = progress["total_bytes"].to_i
    last_update = progress["last_update"].to_i
    error       = progress["error"]

    if status == "running" && last_update > 0 && (Time.current.to_i - last_update > 120)
      return render json: { status: "stopped", processed: processed, total: total, bytes_read: bytes_read, total_bytes: total_bytes }
    end

    if status == "failed"
      return render json: { status: "failed", processed: processed, total: total, bytes_read: bytes_read, total_bytes: total_bytes, error: error }
    end

    render json: { status: status, processed: processed, total: total, bytes_read: bytes_read, total_bytes: total_bytes }
  end
end

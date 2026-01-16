class Mhc::DeaImportProgressController < ApplicationController
  def show
    job_id = params[:job_id]
    key    = "dea_import:#{job_id}"

    progress = $redis.hgetall(key)
    return render json: { status: "not_found" } if progress.blank?

    status      = progress["status"]
    processed   = progress["processed"].to_i
    total       = progress["total"].to_i
    last_update = progress["last_update"].to_i
    error       = progress["error"]

    # Sidekiq stopped / no updates
    if status == "running" && last_update > 0 && (Time.current.to_i - last_update > 60)
      return render json: { status: "stopped", processed: processed, total: total }
    end

    if status == "failed"
      return render json: { status: "failed", processed: processed, total: total, error: error }
    end

    if status == "finished"
      return render json: { status: "finished", processed: processed, total: total }
    end

    render json: { status: status, processed: processed, total: total }
  end
end

class Mhc::DeaImportProgressController < ApplicationController
  def show
    job_id = params[:job_id]
    redis = $redis
    key = "dea_import:#{job_id}"

    progress = redis.hgetall(key)

    # No job found in Redis
    return render json: { status: "not_found" } if progress.blank?

    status    = progress["status"]
    processed = progress["processed"]&.to_i
    total     = progress["total"]&.to_i
    last_ping = progress["last_update"]&.to_i

    # SIDEKIQ STOPPED (no activity)
    if last_ping.present? && last_ping > 0 && (Time.now.to_i - last_ping > 10)
      return render json: { status: "stopped" }
    end

    # Job finished
    if status == "finished"
      return render json: {
        status: "finished",
        processed: processed,
        total: total
      }
    end

    # Job running
    return render json: {
      status: "working",
      processed: processed,
      total: total
    }
  end
end

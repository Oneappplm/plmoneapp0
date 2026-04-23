class Mhc::DeaImportProgressController < ApplicationController
  def show
    job_id = params[:job_id]
    key = "dea_import:#{job_id}"

    progress = $redis.hgetall(key)
    return render json: { status: "not_found" } if progress.blank?

    render json: {
      status: progress["status"].to_s,
      processed: progress["processed"].to_i,
      total: progress["total"].to_i,
      bytes_read: progress["bytes_read"].to_i,
      total_bytes: progress["total_bytes"].to_i,
      error: progress["error"].to_s
    }
  end
end

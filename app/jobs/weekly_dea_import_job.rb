class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import

  REDIS_TTL_SECONDS = 6.hours.to_i

  def perform(upload_id)
    key = "dea_import:#{job_id}"

    upload = DeaImportUpload.find_by(id: upload_id)
    unless upload&.file&.path.present?
      return fail_job!(key, "Upload record not found or file missing (upload_id=#{upload_id})")
    end

    path = upload.file.path
    unless File.exist?(path)
      return fail_job!(key, "File not found on disk: #{path}")
    end

    Rails.logger.info("[DEA IMPORT] job_id=#{job_id} upload_id=#{upload_id} start")
    Rails.logger.info("[DEA IMPORT] path=#{path}")

    # Count total lines ONCE (slow but correct)
    total_lines = File.foreach(path).count

    $redis.multi do |r|
      r.hset(key, "status", "running")
      r.hset(key, "processed", 0)
      r.hset(key, "total", total_lines)
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    DeaMasterImporter.new(path, job_id).import!

    $redis.multi do |r|
      r.hset(key, "status", "finished")
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    # Cleanup uploaded file
    upload.remove_file!
    upload.destroy!
  rescue => e
    Rails.logger.error("[DEA IMPORT] FAILED job_id=#{job_id}: #{e.class} #{e.message}")
    fail_job!(key, "#{e.class}: #{e.message}")
    raise
  end

  private

  def fail_job!(key, msg)
    $redis.multi do |r|
      r.hset(key, "status", "failed")
      r.hset(key, "error", msg.to_s[0, 500])
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
  rescue
  end
end

# app/jobs/weekly_dea_import_job.rb
class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import

  REDIS_TTL_SECONDS = 6.hours.to_i

  def perform(upload_id_or_path)
    redis = $redis
    key   = "dea_import:#{job_id}"

    Rails.logger.info("[DEA IMPORT] job_id=#{job_id} arg=#{upload_id_or_path.inspect} start")

    path = resolve_path(upload_id_or_path)

    unless path.present? && File.exist?(path)
      return fail!(redis, key, "File missing on worker. arg=#{upload_id_or_path.inspect} resolved_path=#{path.inspect}")
    end

    redis.multi do |r|
      r.hset(key, "status", "running")
      r.hset(key, "processed", 0)
      r.hset(key, "total", 0) # unknown
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    Rails.logger.info("[DEA IMPORT] Importing... path=#{path}")
    DeaMasterImporter.new(path, job_id).import!

    redis.multi do |r|
      r.hset(key, "status", "finished")
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    # cleanup only if we got an upload id
    cleanup_upload!(upload_id_or_path)
  rescue => e
    Rails.logger.error("[DEA IMPORT] job_id=#{job_id} FAILED: #{e.class} #{e.message}")
    fail!(redis, key, "#{e.class}: #{e.message}")
    raise
  end

  private

  def resolve_path(upload_id_or_path)
    # If argument is already a full path, use it.
    if upload_id_or_path.is_a?(String) && upload_id_or_path.include?("/uploads/")
      return upload_id_or_path
    end

    # Otherwise treat it as DeaImportUpload id
    upload = DeaImportUpload.find_by(id: upload_id_or_path)
    upload&.file&.path
  end

  def cleanup_upload!(upload_id_or_path)
    return unless upload_id_or_path.is_a?(Integer) || upload_id_or_path.to_s.match?(/\A\d+\z/)

    upload = DeaImportUpload.find_by(id: upload_id_or_path)
    return unless upload

    upload.remove_file!
    upload.destroy!
  rescue => e
    Rails.logger.warn("[DEA IMPORT] cleanup failed: #{e.class} #{e.message}")
  end

  def fail!(redis, key, msg)
    redis.multi do |r|
      r.hset(key, "status", "failed")
      r.hset(key, "error", msg.to_s[0, 500])
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
  rescue
  end
end

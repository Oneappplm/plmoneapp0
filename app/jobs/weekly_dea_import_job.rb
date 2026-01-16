require "open-uri"

class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import
  REDIS_TTL_SECONDS = 6.hours.to_i

  def perform(upload_id)
    key = "dea_import:#{job_id}"

    upload = DeaImportUpload.find_by(id: upload_id)
    unless upload&.file.present?
      return fail!(key, "Upload record not found (upload_id=#{upload_id})")
    end

    $redis.multi do |r|
      r.hset(key, "status", "running")
      r.hset(key, "processed", 0)
      r.hset(key, "total", 0)
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    path, needs_cleanup = resolve_local_path(upload)

    # total lines (exact X/total)
    total_lines = File.foreach(path).count
    $redis.hset(key, "total", total_lines)

    DeaMasterImporter.new(path, job_id).import!

    $redis.multi do |r|
      r.hset(key, "status", "finished")
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    File.delete(path) if needs_cleanup && File.exist?(path)

    # cleanup original upload
    upload.remove_file!
    upload.destroy!
  rescue => e
    fail!(key, "#{e.class}: #{e.message}")
    raise
  end

  private

  # Returns [local_path, needs_cleanup_bool]
  def resolve_local_path(upload)
    # ✅ Local storage case
    if upload.file.path.present? && File.exist?(upload.file.path)
      return [upload.file.path, false]
    end

    # ✅ S3/fog case: download to tmp
    url = upload.file.url
    raise "Missing file url" if url.blank?

    tmp_dir = Rails.root.join("tmp", "dea_imports")
    FileUtils.mkdir_p(tmp_dir)
    tmp_path = tmp_dir.join("dea_#{upload.id}_#{Time.now.to_i}.txt").to_s

    URI.open(url, "rb") do |remote|
      File.open(tmp_path, "wb") { |f| IO.copy_stream(remote, f) }
    end

    raise "Download failed" unless File.exist?(tmp_path) && File.size(tmp_path) > 0
    [tmp_path, true]
  end

  def fail!(key, msg)
    $redis.multi do |r|
      r.hset(key, "status", "failed")
      r.hset(key, "error", msg.to_s[0, 500])
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
  rescue
  end
end

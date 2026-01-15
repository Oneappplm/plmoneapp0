# app/jobs/weekly_dea_import_job.rb
class WeeklyDeaImportJob < ApplicationJob
  queue_as :default

  REDIS_TTL_SECONDS = 6.hours.to_i

  def perform(file_path)
    job_id = self.job_id
    redis  = $redis
    key    = "dea_import:#{job_id}"

    raise "File not found: #{file_path}" unless File.exist?(file_path)

    total_lines = count_lines(file_path)

    redis.multi do |r|
      r.hset(key, "status", "running")
      r.hset(key, "processed", 0)
      r.hset(key, "total", total_lines)
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    # 🔥 Directly process the CarrierWave file
    DeaMasterImporter.new(file_path, job_id).import!

    redis.multi do |r|
      r.hset(key, "status", "completed")
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

  rescue => e
    redis.multi do |r|
      r.hset(key, "status", "failed")
      r.hset(key, "error", e.message.to_s[0, 500])
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
    raise
  end

  private

  def count_lines(path)
    count = 0
    File.foreach(path) { count += 1 }
    count
  end
end

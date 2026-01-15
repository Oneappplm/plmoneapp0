# app/jobs/weekly_dea_import_job.rb
class WeeklyDeaImportJob < ApplicationJob
  queue_as :default

  REDIS_TTL_SECONDS = 6.hours.to_i

  def perform(filepath)
    return unless File.exist?(filepath)

    job_id = self.job_id
    redis  = $redis
    key    = "dea_import:#{job_id}"

    total_lines = count_lines(filepath) # still a pass, but isolated

    redis.multi do |r|
      r.hset(key, "status", "running")
      r.hset(key, "processed", 0)
      r.hset(key, "total", total_lines)
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end

    DeaMasterImporter.new(filepath, job_id).import!

    File.delete(filepath) if File.exist?(filepath)
  rescue => e
    # mark failed
    redis = $redis
    redis.multi do |r|
      r.hset(key, "status", "failed")
      r.hset(key, "error", e.message.to_s.truncate(500))
      r.hset(key, "last_update", Time.current.to_i)
      r.expire(key, REDIS_TTL_SECONDS)
    end
    raise
  end

  private

  def count_lines(path)
    # Very simple & reliable. If you want the absolute fastest: use `wc -l` via Open3, but this is portable.
    c = 0
    File.foreach(path) { c += 1 }
    c
  end
end

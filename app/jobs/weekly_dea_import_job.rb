class WeeklyDeaImportJob < ApplicationJob
  queue_as :default

  def perform(filepath)
    return unless File.exist?(filepath)   # FIX: old jobs won't crash

    job_id = self.job_id
    redis = $redis

    total_lines = File.foreach(filepath).count

    redis.hmset(
      "dea_import:#{job_id}",
      "status", "running",
      "processed", 0,
      "total", total_lines,
      "last_update", Time.now.to_i
    )

    DeaMasterImporter.new(filepath, job_id).import!

    File.delete(filepath) if File.exist?(filepath)
  end
end

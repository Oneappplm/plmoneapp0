# app/jobs/weekly_dea_import_job.rb
class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import

  def perform(upload_id)
    Rails.logger.info "[DEA IMPORT] start job_id=#{job_id} upload_id=#{upload_id}"

    upload = DeaImportUpload.find_by(id: upload_id)
    raise "Upload not found (#{upload_id})" unless upload

    key = "dea_import:#{job_id}"
    $redis.hset(key, "status", "running")
    $redis.hset(key, "last_update", Time.current.to_i)

    file_path =
      if upload.s3_key.present?
        download_from_s3!(upload.s3_key)
      else
        # local carrierwave path
        upload.file.path
      end

    raise "File missing: #{file_path}" unless file_path && File.exist?(file_path)

    DeaMasterImporter.new(file_path, job_id).import!

    $redis.hset(key, "status", "finished")
    $redis.hset(key, "last_update", Time.current.to_i)

  rescue => e
    Rails.logger.error "[DEA IMPORT] FAILED job_id=#{job_id} #{e.class}: #{e.message}"
    $redis.hset(key, "status", "failed")
    $redis.hset(key, "error", "#{e.class}: #{e.message}")
    $redis.hset(key, "last_update", Time.current.to_i)
    raise
  ensure
    # cleanup tmp downloaded file only
    if defined?(file_path) && file_path.present? && file_path.include?("/tmp/dea_import_") && File.exist?(file_path)
      File.delete(file_path) rescue nil
    end
  end

  private

  def download_from_s3!(s3_key)
    require "aws-sdk-s3"

    region = ENV["AWS_REGION"] || "us-east-1"
    bucket = ENV["AWS_S3_BUCKET"] || "plmhealthoneapp-hvhs"
    access = ENV["AWS_ACCESS_KEY_ID"]
    secret = ENV["AWS_SECRET_ACCESS_KEY"]

    raise "AWS creds missing in ENV" if access.blank? || secret.blank?

    s3 = Aws::S3::Client.new(
      region: region,
      access_key_id: access,
      secret_access_key: secret
    )

    tmp_path = "/tmp/dea_import_#{SecureRandom.hex(8)}.txt"
    s3.get_object(bucket: bucket, key: s3_key, response_target: tmp_path)
    tmp_path
  end
end

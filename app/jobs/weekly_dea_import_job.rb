require "aws-sdk-s3"

class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import
  REDIS_TTL_SECONDS = 6.hours.to_i

  def perform(upload_id)
    upload = DeaImportUpload.find_by(id: upload_id)
    redis_key = "dea_import:#{job_id}"

    unless upload&.file.present?
      return fail!(redis_key, "Upload record not found or file missing (upload_id=#{upload_id}).")
    end

    source = upload.file.to_s

    $redis.hset(redis_key, "status", "running")
    $redis.hset(redis_key, "last_update", Time.current.to_i)

    tmp_dir = Rails.root.join("tmp", "dea_imports")
    FileUtils.mkdir_p(tmp_dir)

    # If file is a local path, use it directly.
    # If it looks like an S3 key (no leading / and contains dea_imports/), download first.
    local_path =
      if File.exist?(source)
        source
      else
        tmp_path = tmp_dir.join("dea_#{upload.id}_#{Time.current.to_i}.txt").to_s
        total_bytes = $redis.hget(redis_key, "total_bytes").to_i
        download_from_s3!(source, tmp_path, redis_key: redis_key, total_bytes: total_bytes)
        tmp_path
      end

    DeaMasterImporter.new(local_path, job_id).import!

    $redis.multi do |r|
      r.hset(redis_key, "status", "finished")
      r.hset(redis_key, "last_update", Time.current.to_i)
      r.expire(redis_key, REDIS_TTL_SECONDS)
    end
  ensure
    upload&.destroy
  end

  private

  def s3_client
    Aws::S3::Client.new(
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
  end

  def download_from_s3!(s3_key, dest_path, redis_key:, total_bytes:)
    bucket = ENV.fetch("AWS_S3_BUCKET", "plmhealthoneapp-hvhs")

    bytes = 0
    last_report = 0

    File.open(dest_path, "wb") do |file|
      s3_client.get_object(bucket: bucket, key: s3_key) do |chunk|
        file.write(chunk)
        bytes += chunk.bytesize

        if bytes - last_report >= 5 * 1024 * 1024
          last_report = bytes
          $redis.pipelined do |r|
            r.hset(redis_key, "bytes_read", bytes)
            r.hset(redis_key, "total_bytes", total_bytes)
            r.hset(redis_key, "last_update", Time.current.to_i)
          end
        end
      end
    end

    $redis.hset(redis_key, "bytes_read", bytes)
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

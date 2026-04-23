class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import

  def perform(upload_id)
    progress_key = "dea_import:#{job_id}"

    $redis.hset(progress_key, "status", "running")
    $redis.hset(progress_key, "last_update", Time.current.to_i)

    upload = DeaImportUpload.find_by(id: upload_id)
    raise "Upload not found" unless upload

    temp_file = nil

    file_path =
      if upload.s3_key.present?
        Rails.logger.info("[DEA JOB] Downloading from S3...")
        temp_file = download_from_s3!(upload.s3_key)
      else
        Rails.logger.info("[DEA JOB] Using local file...")

        local_path =
          if upload.file.respond_to?(:current_path) && upload.file.current_path.present?
            upload.file.current_path
          else
            upload.file.path
          end

        if local_path.present? && !Pathname.new(local_path).absolute?
          local_path = Rails.root.join("public", local_path).to_s
        end

        local_path
      end

    raise "File missing: #{file_path}" unless file_path.present? && File.exist?(file_path)

    total_bytes = File.size(file_path).to_i
    $redis.hset(progress_key, "total_bytes", total_bytes)

    DeaMasterImporter.new(file_path, job_id).import!

    $redis.hset(progress_key, "status", "finished")
    $redis.hset(progress_key, "last_update", Time.current.to_i)
  rescue => e
    $redis.hset(progress_key, "status", "failed")
    $redis.hset(progress_key, "error", e.message)
    $redis.hset(progress_key, "last_update", Time.current.to_i)
    raise
  ensure
    if temp_file.present? && File.exist?(temp_file)
      File.delete(temp_file) rescue nil
    end
  end

  private

  def download_from_s3!(key)
    require "aws-sdk-s3"

    bucket = ENV.fetch("AWS_S3_BUCKET", "plmhealthoneapp-hvhs")
    region = ENV.fetch("AWS_REGION", "us-east-1")

    s3 = Aws::S3::Client.new(
      region: region,
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
    )

    tmp_dir = Rails.root.join("tmp")
    FileUtils.mkdir_p(tmp_dir)

    tmp_path = tmp_dir.join("dea_import_#{SecureRandom.hex(8)}.txt").to_s
    s3.get_object(bucket: bucket, key: key, response_target: tmp_path)
    tmp_path
  end
end

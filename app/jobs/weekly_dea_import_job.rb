class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import

  def perform(upload_id)
    upload = DeaImportUpload.find_by(id: upload_id)
    raise "Upload not found" unless upload

    file_path =
      if upload.s3_key.present?
        Rails.logger.info("[DEA JOB] Downloading from S3...")
        download_from_s3!(upload.s3_key)
      else
        Rails.logger.info("[DEA JOB] Using local file...")
        upload.file.path
      end

    raise "File missing: #{file_path}" unless file_path.present? && File.exist?(file_path)

    Rails.logger.info("[DEA JOB] Starting import...")

    DeaMasterImporter.new(file_path, job_id).import!

    Rails.logger.info("[DEA JOB] Import finished")
  end

  private

  def download_from_s3!(key)
    require "aws-sdk-s3"

    s3 = Aws::S3::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    bucket = ENV["AWS_S3_BUCKET"]

    tmp_path = Rails.root.join("tmp", "dea_#{SecureRandom.hex}.txt").to_s

    s3.get_object(bucket: bucket, key: key, response_target: tmp_path)

    tmp_path
  end
end

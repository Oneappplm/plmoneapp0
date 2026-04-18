class WeeklyDeaImportJob < ApplicationJob
  queue_as :dea_import

  def perform(upload_id)
    upload = DeaImportUpload.find_by(id: upload_id)
    raise "Upload not found: #{upload_id}" unless upload

    file_path =
      if upload.s3_key.present?
        download_from_s3!(upload.s3_key)
      else
        upload.file.path
      end

    raise "File missing: #{file_path}" unless file_path.present? && File.exist?(file_path)

    DeaMasterImporter.new(file_path, job_id).import!
  ensure
    if defined?(file_path) && file_path.present? && file_path.include?("/tmp/dea_import_") && File.exist?(file_path)
      File.delete(file_path) rescue nil
    end
  end

  private

  def download_from_s3!(key)
    require "aws-sdk-s3"

    region = ENV.fetch("AWS_REGION", "us-east-1")
    bucket = ENV.fetch("AWS_S3_BUCKET", "plmhealthoneapp-hvhs")

    s3 = Aws::S3::Client.new(
      region: region,
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
    )

    tmp_path = "/tmp/dea_import_#{SecureRandom.hex(8)}.txt"
    s3.get_object(bucket: bucket, key: key, response_target: tmp_path)
    tmp_path
  end
end

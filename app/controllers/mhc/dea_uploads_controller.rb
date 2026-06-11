class Mhc::DeaUploadsController < ApplicationController
  protect_from_forgery with: :exception

  def presign
    require "aws-sdk-s3"

    bucket = ENV.fetch("AWS_S3_BUCKET", "docgotest-bucket")
    region = ENV.fetch("AWS_REGION", "ap-south-1")

    creds = Aws::Credentials.new(
      ENV.fetch("AWS_ACCESS_KEY_ID"),
      ENV.fetch("AWS_SECRET_ACCESS_KEY")
    )

    s3 = Aws::S3::Resource.new(region: region, credentials: creds)
    obj_key = build_key(params[:filename])

    presigned = s3.bucket(bucket).object(obj_key).presigned_url(
      :put,
      expires_in: 1800,
      content_type: params[:content_type].presence || "application/octet-stream"
    )

    render json: { url: presigned, key: obj_key }
  rescue => e
    Rails.logger.error("[DEA UPLOAD] presign failed: #{e.class} #{e.message}")
    render json: { error: e.message }, status: 500
  end

  private

  def build_key(filename)
    safe_name = filename.to_s.gsub(/[^a-zA-Z0-9\.\-_]/, "_")
    "dea_imports/#{Time.current.strftime("%Y/%m/%d")}/#{SecureRandom.uuid}-#{safe_name}"
  end
end

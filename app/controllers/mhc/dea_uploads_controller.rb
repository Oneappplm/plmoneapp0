class Mhc::DeaUploadsController < ApplicationController
  def presign
    filename     = params.require(:filename)
    content_type = params[:content_type].presence || "application/octet-stream"

    key = "dea_imports/#{Time.current.strftime("%Y/%m/%d")}/#{SecureRandom.uuid}-#{filename}"

    s3 = Aws::S3::Resource.new(
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    bucket = s3.bucket(ENV.fetch("AWS_S3_BUCKET", "plmhealthoneapp-hvhs"))
    obj = bucket.object(key)

    url = obj.presigned_url(:put, expires_in: 30.minutes.to_i, content_type: content_type)

    render json: { url: url, key: key }
  end
end

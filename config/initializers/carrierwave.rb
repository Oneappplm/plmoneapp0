# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    config.fog_provider = "fog/aws"

    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
      region: ENV.fetch("AWS_REGION", "us-west-4"),
      endpoint: ENV.fetch(
        "AWS_ENDPOINT",
        "https://s3.us-west-4.idrivee2.com"
      ),
      path_style: true
    }

    config.fog_directory =
      ENV.fetch("AWS_S3_BUCKET")

    config.fog_public = false
    config.fog_use_ssl_for_aws = true
    config.fog_authenticated_url_expiration = 10.minutes.to_i

    config.fog_attributes = {
      "Cache-Control" => "private, max-age=#{365.days.to_i}"
    }
  else
    config.storage = :file
  end
end
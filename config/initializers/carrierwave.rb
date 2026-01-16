# config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog   # ✅ IMPORTANT LINE (this was missing)

    config.fog_provider = "fog/aws"
    config.fog_credentials = {
      provider:              "AWS",
      aws_access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region:                ENV.fetch("AWS_REGION", "us-east-1")
    }

    config.fog_directory  = ENV.fetch("AWS_S3_BUCKET", "plmhealthoneapp-hvhs")
    config.fog_public     = false
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }

  else
    config.storage = :file
  end
end

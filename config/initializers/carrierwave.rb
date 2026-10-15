CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
    region: ENV.fetch("AWS_REGION", "us-east-1")
  }

  config.fog_directory = ENV.fetch("AWS_BUCKET", "plmhealthoneapp-hvhs")

  config.storage = :fog
  config.fog_public = false
  config.fog_attributes = {cache_control: "public, max-age=#{365.days.to_i}"}
end

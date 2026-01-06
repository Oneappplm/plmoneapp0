CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region:                'us-east-1'
  }

  config.fog_directory  = 'plmhealthoneapp-hvhs'

  # ✅ Don’t set ACLs if the bucket blocks them
  config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  config.fog_public     = false     # Important: disables automatic ACL = public-read
end

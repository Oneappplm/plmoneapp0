# frozen_string_literal: true

require "aws-sdk-s3"

class DeaStorage
  def self.bucket
    ENV.fetch("AWS_S3_BUCKET")
  end

  def self.client
    Aws::S3::Client.new(
      region: ENV.fetch("AWS_REGION", "us-west-4"),
      endpoint: ENV.fetch(
        "AWS_ENDPOINT",
        "https://s3.us-west-4.idrivee2.com"
      ),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
      force_path_style: true
    )
  end

  def self.resource
    Aws::S3::Resource.new(client: client)
  end
end
# frozen_string_literal: true

require "fog/aws"

module Dmf
  class ArtifactStore
    class DownloadError < StandardError; end

    def download(key, destination_path)
      raise DownloadError, "DMF artifact key is missing." if key.blank?

      File.open(destination_path, "wb") do |file|
        connection.get_object(bucket_name, key) do |chunk|
          file.write(chunk)
        end
      end

      destination_path
    rescue StandardError => error
      Rails.logger.error(
        "[DMF ArtifactStore] " \
        "key=#{key.inspect} " \
        "#{error.class}: #{error.message}"
      )

      raise DownloadError,
            "Unable to download DMF artifact: #{error.message}"
    end

    private

    def connection
      @connection ||= Fog::Storage.new(
        provider: "AWS",
        aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key:
          ENV.fetch("AWS_SECRET_ACCESS_KEY"),
        region: ENV.fetch("AWS_REGION", "us-west-4"),
        endpoint: ENV.fetch(
          "AWS_ENDPOINT",
          "https://s3.us-west-4.idrivee2.com"
        ),
        path_style: true
      )
    end

    def bucket_name
      ENV["AWS_S3_BUCKET"].presence ||
        ENV.fetch("AWS_BUCKET")
    end
  end
end
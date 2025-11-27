# config/initializers/sidekiq.rb

require "sidekiq"

redis_url =
  ENV["REDIS_URL"] ||
  "redis://default:#{ENV['REDIS_PASSWORD']}@10.0.1.213:6379/0"

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    namespace: "docgo-demo"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    namespace: "docgo-demo"
  }
end

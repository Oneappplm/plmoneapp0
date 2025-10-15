redis_url = ENV.fetch("REDIS_URL") { "redis://default:65a314d18ddc074608e003c3@10.0.1.213:6379/0" }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

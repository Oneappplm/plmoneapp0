require_relative "boot"

require "rails/all"
require "faker"
require 'csv'
require 'sys/filesystem'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlmhealthoneApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOW-FROM https://bcbs.webcvo.net',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff',
      'SameSite' => 'None'
     }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
      end
    end

    config.eager_load_paths << Rails.root.join('lib')

    # SMTP settings for gmail
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.default_url_options = { host: Figaro.env.smtp_host }
    config.action_mailer.smtp_settings = {
      :address              => Figaro.env.smtp_address,
      :port                 => Figaro.env.smtp_port,
      :user_name            => Figaro.env.smtp_email,
      :password             => Figaro.env.smtp_password,
      :authentication       => "plain",
      :enable_starttls_auto => true
    }

  end
end

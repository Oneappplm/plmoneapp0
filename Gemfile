source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
# gem "sqlite3", "~> 1.4"
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem 'will_paginate-bootstrap-style' #https://github.com/delef/will_paginate-bootstrap-style
# Use Sass to process CSS
# gem "sassc-rails"

# placed this so I can create dummy records on live we can just delete fake record later.
gem 'faker' #https://github.com/faker-ruby/faker
gem 'countries', require: 'countries/global' #https://github.com/countries/countries
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem 'pry', '~> 0.14.2'
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'letter_opener_web' # https://github.com/fgrehm/letter_opener_web
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
end

# additional gems
gem 'pg_search' # https://github.com/Casecommons/pg_search
gem 'will_paginate', '~> 3.3' # https://github.com/mislav/will_paginate
gem "devise", "~> 4.8" # https://github.com/heartcombo/devise
gem "roo", "~> 2.9.0" # https://github.com/roo-rb/roo
gem 'carrierwave', '>= 3.0.0.beta', '< 4.0' # https://github.com/carrierwaveuploader/carrierwave
gem "fog-aws" # https://github.com/fog/fog-aws
gem 'rack-cors'
gem 'nokogiri'
gem 'mechanize', '~> 2.7', '>= 2.7.6'
gem 'active_model_serializers'
gem 'devise_invitable', '~> 2.0.0' # https://github.com/scambra/devise_invitable
gem "selenium-webdriver"
# gem "webdrivers"
gem 'prawn'
gem 'sys-filesystem' # https://github.com/djberg96/sys-filesystem/tree/32bit_linux
gem "ahoy_matey" # https://github.com/ankane/ahoy'gem 'device_detector'
gem 'device_detector' # https://github.com/podigee/device_detector
gem "noticed", "~> 1.6"
gem 'draper' # https://github.com/drapergem/draper
gem "figaro" # https://github.com/laserlemon/figaro
gem 'exception_notification' # https://github.com/smartinez87/exception_notification
gem "geocoder" # https://github.com/alexreisner/geocoder
gem "audited" # https://github.com/collectiveidea/audited
gem 'chunky_png', '~> 1.3', '>= 1.3.5'
gem 'combine_pdf'

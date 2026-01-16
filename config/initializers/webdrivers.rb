# config/initializers/webdrivers.rb

require 'webdrivers'

# Stop the gem from auto-downloading a driver
Webdrivers::Chromedriver.required_version = '140.0.7339.127'

# Point Selenium directly to the driver you manually installed
Selenium::WebDriver::Chrome::Service.driver_path = '/usr/bin/chromedriver'

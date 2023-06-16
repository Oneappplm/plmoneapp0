# frozen_string_literal: true

require 'selenium-webdriver'
require 'webdrivers'

class ApplicationService
  SCREENSHOT_FILENAME = 'screenshot.png'
  PDF_FILENAME = 'screenshot.pdf'
  PUBLIC_PATH = Rails.root.join('public', 'webscrape')

  attr_reader :crawler_folder

  def self.call(*args, &block)
    new(*args, &block).call
  end

  protected

  def crawl
    begin
      initialize_folder_path!
			crawl!
			success!
		rescue => exception
      save_screenshot
			crawler.quit() if crawler
			error!(exception)
		end
  end

  def crawler
    if Rails.env.development?
			options = Selenium::WebDriver::Chrome::Options.new
		else
			Selenium::WebDriver::Chrome.path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
			options = Selenium::WebDriver::Chrome::Options.new(
					prefs: { 'profile.default_content_setting_values.notifications': 2 },
					binary: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
			)
		end

    # uncomment the following line to run headless else comment it out to run in browser
		options.add_argument('--headless')

		options.add_argument('--disable-gpu')
		options.add_argument('--no-sandbox')

		@crawler ||= Selenium::WebDriver.for :chrome, options: options
  end

  def crawl!
    nil
  end

  def success!
    {
      status: 'success',
      message: 'Scraping completed successfully!'
    }
  end

  def error! e
    {
      status: 'error',
      message: "An error occurred during scraping: #{e.message}"
    }
  end

  def save_screenshot
    crawler.manage.window.resize_to(1024, 1024)
		crawler.save_screenshot(PUBLIC_PATH.join(crawler_folder_name, SCREENSHOT_FILENAME))
  end

  def initialize_folder_path!
    FileUtils.mkdir_p(PUBLIC_PATH.join(crawler_folder_name))
    FileUtils.rm_f(PUBLIC_PATH.join(crawler_folder_name, SCREENSHOT_FILENAME))
  end

  def crawler_folder_name
    crawler_folder || 'crawler'
  end
end

require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class KansasScraper
      SEARCH_URL = "https://www.kansas.gov/dental-verification/start.do".freeze

      def initialize(license_number, state, url = nil)
        @license_number = license_number
        @state = state
        @url = url || SEARCH_URL
      end

      def call
        crawl!
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        crawler.find_element(:id, 'licNum')
               .send_keys(@license_number)

        puts "➡️ Clicking search button..."
        search_button = fast_wait.until {
          crawler.find_element(:xpath, "//button[@name='_eventId_submit' or contains(text(),'Search')]")
        }
        search_button.click

        puts "⏳ Waiting for redirect..."
        wait_for_redirect

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
        puts "➡️ Closing browser..."
        crawler.quit if @crawler
      end

      private

      # Selenium headless browser
      def crawler
        @crawler ||= Selenium::WebDriver.for(:chrome, options: chrome_options)
      end

      def chrome_options
        opts = Selenium::WebDriver::Chrome::Options.new
        opts.add_argument("--headless=new")   # 👈 headless Chrome
        opts.add_argument("--disable-gpu")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--window-size=1400,2000")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 4)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 15)
      end

      def wait_for_redirect
        slow_wait.until { crawler.current_url.include?('LicenseVerification') }
      rescue
        puts "⚠️ Redirect timeout reached"
      end

      # def save_screenshot
      #   dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
      #   FileUtils.mkdir_p(dir)

      #   path = dir.join("#{@state.name}_#{@license_number}.png").to_s
      #   crawler.save_screenshot(path)

      #   # Return URL accessible via browser
      #   "/webscrape/Licensure/#{@state.alpha_code}/#{@state.name}_#{@license_number}.png"
      # end
      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "#{@state.name}_#{@license_number}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        # 1️⃣ Take raw screenshot
        crawler.save_screenshot(path)

        # 2️⃣ Add timestamp (e.g. "2025-12-18")
        human_date = Time.current.strftime("%Y-%m-%d")

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "NorthWest"          # top-left as origin
          c.fill "black"
          c.pointsize 14
          c.draw "text 160,1120 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

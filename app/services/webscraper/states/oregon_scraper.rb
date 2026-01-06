require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class OregonScraper
      # SEARCH_URL = "https://omb.oregon.gov/search".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url
      end

      def call
        crawl!
      rescue => e
        puts "❌ Scraper error: #{e.message}"
        puts e.backtrace
        nil
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."

        license_input = fast_wait.until do
          el = crawler.find_element(:css, "input[name='licenseNumber']")
          el if el.displayed?
        end

        license_input.clear
        license_input.send_keys(@license_number)

        puts "➡️ Clicking Search button..."

        search_btn = fast_wait.until do
          crawler.find_element(:css, "button[ng-click='c.search()']")
        end

        crawler.execute_script("arguments[0].scrollIntoView(true);", search_btn)
        sleep 0.3
        crawler.execute_script("arguments[0].click();", search_btn)

        puts "⏳ Waiting for new window to open..."
        switch_to_new_window

        puts "⏳ Waiting for results page (VerificationDetails)..."
        wait_for_verification_page

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
        puts "➡️ Closing browser..."
        crawler.quit if @crawler
      end

      private

      def crawler
        @crawler ||= Selenium::WebDriver.for(:chrome, options: chrome_options)
      end

      def chrome_options
        opts = Selenium::WebDriver::Chrome::Options.new
        opts.add_argument("--headless=new")
        opts.add_argument("--disable-gpu")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--window-size=1400,2000")

        # important
        opts.add_argument("--disable-popup-blocking")
        opts.add_argument("--allow-popups-during-page-unload")
        opts.add_argument("--disable-features=IsolateOrigins,site-per-process")
        opts.add_argument("--disable-site-isolation-trials")

        opts
      end


      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 6)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      def switch_to_new_window
        original = crawler.window_handle

        begin
          slow_wait.until { crawler.window_handles.size > 1 }
        rescue Selenium::WebDriver::Error::TimeoutError
          puts "⚠️ No new window detected. Staying on same window."
          return
        end

        new_window = (crawler.window_handles - [original]).first
        crawler.switch_to.window(new_window)
        puts "➡️ Switched to results window"
      end


      def wait_for_verification_page
        slow_wait.until do
          url = crawler.current_url
          url.include?("VerificationDetails") || url.include?("LicenseVerification")
        end
      rescue
        puts "⚠️ Verification page load timeout"
      end

      # def save_screenshot
      #   dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
      #   FileUtils.mkdir_p(dir)

      #   filename = "#{@state.name}_#{@license_number}.png"
      #   path = dir.join(filename).to_s
      #   crawler.save_screenshot(path)

      #   "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"
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
        human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "NorthWest"          # top-left as origin
          c.fill "black"
          c.pointsize 14
          c.draw "text 140,80 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

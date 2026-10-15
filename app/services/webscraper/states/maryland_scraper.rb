require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class MarylandScraper
      SEARCH_URL = "https://mdbnc.health.maryland.gov/psychverification/Default.aspx".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url || SEARCH_URL
      end

      def call
        raise "License search URL missing for #{@state.name}" if @url.blank?
        crawl!
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        crawler.find_element(:id, 'bodyContentPlaceHolder_licenseNoSearch').send_keys(@license_number)

        puts "➡️ Clicking search button..."
        crawler.find_element(:id, 'bodyContentPlaceHolder_search2').click

        # 1️⃣ Wait for results table
        slow_wait.until { crawler.find_elements(:xpath, "//a[contains(@href, 'Details.aspx')]").any? }

        # 2️⃣ Click "View Details"
        puts "➡️ Clicking View Details..."
        view_details = crawler.find_element(:xpath, "//a[contains(@href, 'Details.aspx')]")
        view_details.click

        # 3️⃣ Wait for details page and click "Print Verification"
        slow_wait.until { crawler.find_element(:id, "bodyContentPlaceHolder_hy_printVerification") }
        puts "➡️ Clicking Print Verification..."
        
        original_window = crawler.window_handle
        print_link = crawler.find_element(:id, "bodyContentPlaceHolder_hy_printVerification")
        crawler.execute_script("arguments[0].click();", print_link)

        # 4️⃣ Switch to new tab
        slow_wait.until { crawler.window_handles.size > 1 }
        new_handle = (crawler.window_handles - [original_window]).first
        crawler.switch_to.window(new_handle)

        # 5️⃣ Wait for print page to load
        sleep 2

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

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        # 1️⃣ Take raw screenshot
        crawler.save_screenshot(path)

        Rails.logger.info("✅ Screenshot saved at: #{public_url}")

        # 2️⃣ Add timestamp (e.g. "2025-12-18")
        human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "SouthEast"         
          c.fill "black"
          c.pointsize 14
          c.draw "text 30,10 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

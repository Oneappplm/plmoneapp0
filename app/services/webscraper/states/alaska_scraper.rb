require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class AlaskaScraper
      # SEARCH_URL = "https://www.commerce.alaska.gov/cbp/main/Search/Professional".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url
      end

      def call
        raise "License search URL missing for #{@state.name}" if @url.blank?
        crawl!
      end

      def crawl!
        puts "➡️ Opening #{@state.name} site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        crawler.find_element(:id, "LicenseNumber").send_keys(@license_number)

        puts "➡️ Clicking search button..."
        search_button = fast_wait.until do
          crawler.find_element(:id, "search")
        end
        crawler.execute_script("arguments[0].click();", search_button)

        # 🔹 Wait for CAPTCHA modal/popup to appear
        slow_wait.until do
          crawler.find_elements(:css, ".modal, .popup, [role='dialog'], .captcha-container").any? ||
          crawler.find_elements(:css, "iframe[src*='recaptcha']").any?
        end

        # 🔹 Click CAPTCHA checkbox
        captcha_checkbox = fast_wait.until do
          # Try multiple common selectors
          crawler.find_elements(:css, "input[type='checkbox'], #recaptcha input, .recaptcha-checkbox input, input[aria-label*='robot']").first
        end
        crawler.execute_script("arguments[0].click();", captcha_checkbox)

        sleep 2  # wait for checkbox animation & validation

        # 🔹 Click Continue button
        continue_btn = fast_wait.until do
          crawler.find_elements(:css, "button:contains('Continue'), input[value*='Continue'], button[class*='continue'], #continue").first
        end
        crawler.execute_script("arguments[0].click();", continue_btn)

        # 🔹 Wait for results (modal closes, results appear)
        sleep 5

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot
        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
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

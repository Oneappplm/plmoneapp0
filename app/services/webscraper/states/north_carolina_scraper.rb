require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class NorthCarolinaScraper

      SEARCH_URL = "https://portal.ncblcmhc.org/verification/search.aspx".freeze

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
        puts "➡️ Opening #{@state.name} site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        crawler.find_element(:id, 'txtLicenseNumber')
               .send_keys(@license_number)

        puts "➡️ Clicking search button..."
        search_button = fast_wait.until {
          crawler.find_element(:id, "btnAJAX")
        }
        search_button.click

        puts "⏳ Waiting for verification link..."
        click_verification_pdf

        # puts "⏳ Switch to new tab..."
        # switch_to_new_tab

        # sleep 7

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

      def click_verification_pdf
        puts "➡️ Waiting for verification PDF link..."

        link = slow_wait.until do
          crawler.find_element(:id, "hlVerificationLink")
        end

        puts "➡️ Clicking verification PDF link..."
        link.click
      end

      # def switch_to_new_tab
      #   puts "🔄 Switching to PDF tab..."
      #   slow_wait.until { crawler.window_handles.size > 1 }
      #   crawler.switch_to.window(crawler.window_handles.last)
      # end


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

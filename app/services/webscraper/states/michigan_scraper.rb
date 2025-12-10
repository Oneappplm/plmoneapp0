require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class MichiganScraper
      SEARCH_URL = "https://val.apps.lara.state.mi.us/License/Search".freeze

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

        # --- Enter license number ---
        puts "➡️ Entering license number..."
        input = fast_wait.until {
          crawler.find_element(:id, "LicenseNumber")
        }
        input.clear
        input.send_keys(@license_number)

        # --- Click Search button ---
        puts "➡️ Clicking search button..."
        search_button = fast_wait.until {
          crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
        }
        crawler.execute_script("arguments[0].click();", search_button)

        # --- Wait for results list ---
        puts "⏳ Waiting for results..."
        details_link = wait_for_result_link

        if details_link
          puts "➡️ Clicking license details link..."
          crawler.execute_script("arguments[0].click();", details_link)
        else
          puts "⚠️ No records found. Taking screenshot anyway."
        end

        # Allow page load
        sleep 2

        # --- Screenshot ---
        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path

      rescue => e
        puts "❌ Error: #{e.message}"
        raise e
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
        opts.add_argument("--window-size=1600,2400")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 4)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      # Result Link Finder
      
      def wait_for_result_link
        30.times do
          begin
            # Find first details link
            link = crawler.find_element(:xpath, "//a[contains(@href,'/License/Details/')]")
            return link if link.displayed?
          rescue Selenium::WebDriver::Error::NoSuchElementError
            # ignore and retry
          end

          # No results case
          if crawler.page_source.include?("No results found") ||
             crawler.page_source.include?("No records found")
            return nil
          end

          sleep 0.5
        end

        nil
      end

      # Screenshot
      
      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        file_name = "#{@state.name}_#{@license_number}.png"
        full_path = dir.join(file_name).to_s

        crawler.save_screenshot(full_path)

        "/webscrape/Licensure/#{@state.alpha_code}/#{file_name}"
      end
    end
  end
end

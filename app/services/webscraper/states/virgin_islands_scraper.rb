require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class VirginIslandsScraper
      # SEARCH_URL = "https://secure.dlca.vi.gov/license/Asps/Search/License_search.aspx".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url
      end

      def call
        crawl!
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        crawler.find_element(:id, 'ctl00_top_LicSearchcontrol_txtLicNo')
               .send_keys(@license_number)

        puts "➡️ Clicking search button..."
        search_button = fast_wait.until {
          crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
        }
        search_button.click

        puts "⏳ Waiting for redirect..."
        wait_for_redirect

        # puts "➡️ Clicking on license result..."
        # result_link = slow_wait.until do
        #   # Either match by license number in href
        #   crawler.find_element(:xpath, "//a[contains(@href, '/Lookup/Detail/#{@license_number}')]")
        #   # Or match by visible text if you know it: "//a[contains(., 'JAMES M ROBERTSON')]"
        # end

        # crawler.execute_script("arguments[0].scrollIntoView(true);", result_link)
        # crawler.execute_script("arguments[0].click();", result_link)

        # # Optional: wait a moment for details page to load
        # sleep 1

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

        path = dir.join("#{@state.name}_#{@license_number}.png").to_s
        crawler.save_screenshot(path)

        # Return URL accessible via browser
        "/webscrape/Licensure/#{@state.alpha_code}/#{@state.name}_#{@license_number}.png"
      end
    end
  end
end

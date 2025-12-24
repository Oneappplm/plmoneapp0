require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class PennsylvaniaScraper
      # SEARCH_URL = "https://www.pals.pa.gov/#!/page/search".freeze

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

        puts "➡️ Waiting for license input..."
        sleep 2 
        license_input = slow_wait.until do
          el = crawler.find_element(:id, "LicenseNo")
          el if el.displayed? && el.enabled?
        end
        license_input.clear
        license_input.send_keys(@license_number)

        puts "➡️ Waiting for loading overlay to disappear..."
        slow_wait.until do
          overlays = crawler.find_elements(:css, "div.cg-busy.ng-scope")
          overlays.all? { |el| !el.displayed? }
        end

        puts "➡️ Clicking 'Search' button..."
        verify_btn = fast_wait.until do
          btn = crawler.find_element(:xpath, "//button[contains(., 'Search')]")
          btn if btn.displayed? && btn.enabled?
        end
        verify_btn.click

        puts "⏳ Waiting for results to appear..."
        # wait for Angular overlay to disappear again
        slow_wait.until do
          overlays = crawler.find_elements(:class, "ng-binding")
          overlays.all? { |el| !el.displayed? }
        end

        # wait for the specific license link
        puts "➡️ Waiting for result row matching license #{@license_number} ..."

        row = slow_wait.until do
          rows = crawler.find_elements(:xpath, "//tbody/tr[td[contains(text(), '#{@license_number}')]]")
          rows.first if rows.any?
        end

        raise "❌ No row found for license #{@license_number}" unless row

        puts "➡️ Clicking license holder's name..."
        name_link = row.find_element(:xpath, ".//a[contains(@ng-click, 'search.getAssetDetail')]")

        crawler.execute_script("arguments[0].scrollIntoView(true);", name_link)
        crawler.execute_script("arguments[0].click();", name_link)

        # optional wait for details page to load
        sleep 1

        puts "⏳ Waiting for redirect..."
        wait_for_redirect

        # if crawler.current_url.include?('LicenseVerification')
        #   puts "✅ Redirected successfully!"

        #   puts "➡️ Looking for printer-friendly link..."
        #   link = slow_wait.until {
        #     crawler.find_element(:xpath, "//a[contains(., 'Printer Friendly Version')]")
        #   } rescue nil

        #   if link
        #     crawler.execute_script("arguments[0].scrollIntoView();", link)
        #     crawler.execute_script("arguments[0].click();", link)
        #   else
        #     puts "❌ Printer-friendly link not found!"
        #   end
        # else
        #   puts "❌ Not redirected to LicenseVerification page!"
        # end

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
        Selenium::WebDriver::Wait.new(timeout: 15)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 30)
      end

      def wait_for_redirect
        slow_wait.until { crawler.current_url.include?('LicenseVerification') }
      rescue
        puts "⚠️ Redirect timeout reached"
      end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename = "#{@state.name}_#{@license_number}.png"
        path = dir.join(filename).to_s
        crawler.save_screenshot(path)

        # Return URL accessible via browser
        "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"
      end
    end
  end
end

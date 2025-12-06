require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class ArkansasScraper
      SEARCH_URL = "https://www.armedicalboard.org/public/verify/default.aspx".freeze

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

        puts "➡️ Selecting 'License Number' radio button..."
        license_radio = fast_wait.until {
          crawler.find_element(:id, "ctl00_MainContentPlaceHolder_ucVerifyLicense_rbVerifyLicenseSearch_0")
        }
        license_radio.click

        puts "➡️ Entering license number..."
        license_input = fast_wait.until {
          crawler.find_element(:id, "ctl00_MainContentPlaceHolder_ucVerifyLicense_txtVerifyLicNumLastName")
        }
        license_input.clear
        license_input.send_keys(@license_number)

        puts "➡️ Clicking 'Verify' button..."
        verify_btn = fast_wait.until {
          crawler.find_element(:id, "ctl00_MainContentPlaceHolder_ucVerifyLicense_btnVerifyLicense")
        }
        verify_btn.click

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

        filename = "#{@state.name}_#{@license_number}.png"
        path = dir.join(filename).to_s
        crawler.save_screenshot(path)

        # Return URL accessible via browser
        "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"
      end
    end
  end
end

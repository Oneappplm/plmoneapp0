require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class AlaskaScraper

      # SEARCH_URL = "https://www.commerce.alaska.gov/cbp/main/Search/Professional".freeze

      def initialize(license_number, state, url = nil)
        @license_number = license_number
        @state = state
        @url = url || SEARCH_URL
        @driver = build_driver
      end

      def crawl!
        puts "Running Alaska scraper for #{@license_number} at #{@url}"

        @driver.navigate.to(@url)

        # Fill form
        license_input = wait_until { @driver.find_element(id: "LicenseNumber") }
        license_input.clear
        license_input.send_keys(@license_number)

        # Check CAPTCHA
        if captcha_present?
          puts "⚠️ CAPTCHA detected! Please solve it manually..."
          wait_until_captcha_solved
          puts "✔ CAPTCHA solved!"
        end

        # Click search button
        search_button = wait_until { @driver.find_element(id: "search") }
        search_button.click

        sleep 1 # minor wait

        # Parse results
        rows = @driver.find_elements(css: "table tbody tr")

        if rows.empty?
          screenshot_path = take_screenshot("no_results")
          return {
            status: "no_results",
            pdf_path: screenshot_path,
            license_number: @license_number,
            state: @state.alpha_code
          }
        end

        first_row = rows.first

        extracted = {
          name: safe_text(first_row, "td[data-label='Name']"),
          license_type: safe_text(first_row, "td[data-label='License Type']"),
          status_text: safe_text(first_row, "td[data-label='Status']"),
          issue_date: safe_text(first_row, "td[data-label='Issue Date']"),
          expiration_date: safe_text(first_row, "td[data-label='Expiration Date']")
        }

        screenshot_path = take_screenshot("result")

        extracted.merge!(
          status: "success",
          license_number: @license_number,
          state: @state.alpha_code,
          pdf_path: screenshot_path
        )
      ensure
        @driver.quit if @driver
      end

      private

      # 1️⃣ Build Selenium driver
      def build_driver
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--no-sandbox")
        options.add_argument("--window-size=1400,2000")

        Selenium::WebDriver.for(:chrome, options: options)
      end

      # 2️⃣ CAPTCHA detection (pure Selenium)
      def captcha_present?
        @driver.find_elements(css: "iframe[title='reCAPTCHA']").any?
      end

      # 3️⃣ Wait for CAPTCHA to be solved
      def wait_until_captcha_solved(timeout = 300)
        start = Time.now

        while captcha_not_solved?
          sleep 1
          raise "CAPTCHA not solved within #{timeout} seconds" if Time.now - start > timeout
        end
      end

      def captcha_not_solved?
        iframe = @driver.find_elements(css: "iframe[title='reCAPTCHA']").first
        return false unless iframe

        @driver.switch_to.frame(iframe)

        anchor = @driver.find_elements(css: "#recaptcha-anchor").first
        checked = anchor&.attribute("aria-checked") == "false"

        @driver.switch_to.default_content
        checked
      rescue
        false
      end

      # 4️⃣ Screenshot
      def take_screenshot(filename)
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        path = dir.join("#{filename}.png")
        @driver.save_screenshot(path.to_s)
        path.to_s
      end

      # Helpers
      def wait_until(timeout = 10)
        Selenium::WebDriver::Wait.new(timeout: timeout).until { yield }
      end

      def safe_text(row, selector)
        row.find_element(css: selector).text.strip
      rescue
        ""
      end

    end
  end
end

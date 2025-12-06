require "capybara"
require "capybara/dsl"
require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class AlaskaScraper
      include Capybara::DSL

      SEARCH_URL = "https://www.commerce.alaska.gov/cbp/main/Search/Professional".freeze

      def initialize(license_number, state, url = nil)
        @license_number = license_number
        @state = state
        @url = url || SEARCH_URL
        setup_capybara!
      end

      def crawl!
        puts "Running Alaska scraper for #{@license_number} at #{@url}"

        visit @url
        fill_in "LicenseNumber", with: @license_number

        # Check reCAPTCHA inside iframe
        if captcha_present?
          puts "⚠️ CAPTCHA detected! Please solve it manually."
          puts "Waiting for completion..."

          wait_until_captcha_solved

          puts "✔️ CAPTCHA solved automatically detected. Continuing..."
        end

        puts "➡️ Clicking search button..."
        find("#search").click
        
        # sleep 1

        puts "Checking results..."
        results_table = all("table tbody tr")

        if results_table.empty?
          screenshot_path = take_screenshot("no_results")
          return {
            status: "no_results",
            pdf_path: screenshot_path,
            license_number: @license_number,
            state: @state.alpha_code
          }
        end

        first_row = results_table.first

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

      end

      private

      #######################################################################
      ## 1️⃣ Capybara Driver (HEADFUL browser so human can solve CAPTCHA)
      #######################################################################
      def setup_capybara!
        Capybara.register_driver :selenium_chrome_visible do |app|
          options = Selenium::WebDriver::Chrome::Options.new
          options.add_argument("--disable-dev-shm-usage")
          options.add_argument("--no-sandbox")
          options.add_argument("--window-size=1400,2000")

          Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
        end

        Capybara.default_driver = :selenium_chrome_visible
        Capybara.javascript_driver = :selenium_chrome_visible
      end

      #######################################################################
      ## 2️⃣ CAPTCHA detection
      #######################################################################
      def captcha_present?
        return false unless page.has_css?("iframe[title='reCAPTCHA']")

        within_frame(find("iframe[title='reCAPTCHA']")) do
          page.has_css?("#recaptcha-anchor")
        end
      end

      #######################################################################
      ## 3️⃣ Wait until solved
      #######################################################################
      def wait_until_captcha_solved(timeout = 300)
        start = Time.now

        while captcha_not_solved?
          sleep 1
          if Time.now - start > timeout
            raise "CAPTCHA not solved within #{timeout} seconds"
          end
        end
      end

      def captcha_not_solved?
        within_frame(find("iframe[title='reCAPTCHA']")) do
          page.has_css?("#recaptcha-anchor[aria-checked='false']")
        end
      rescue Capybara::ElementNotFound
        false
      end

      #######################################################################
      ## 4️⃣ Screenshot
      #######################################################################
      def take_screenshot(filename)
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        path = dir.join("#{filename}.png")
        save_screenshot(path.to_s)

        path.to_s
      end

      def safe_text(row, selector)
        row.find(selector).text.strip
      rescue
        ""
      end

    end
  end
end

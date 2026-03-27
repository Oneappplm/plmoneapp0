require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class VermontScraper
      SEARCH_URL = "https://secure.professionals.vermont.gov/prweb/PRServletCustom/app/NGLPGuestUser_/V9csDxL3sXkkjMC_FR2HrA*/!STANDARD?UserIdentifier=LicenseLookupGuestUser".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url || SEARCH_URL
      end

      def call
        crawl!
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        license_input = fast_wait.until do
          el = crawler.find_element(:id, "1bf91a94") # Vermont license input ID
          el if el.displayed?
        end
        license_input.clear
        license_input.send_keys(@license_number)

        puts "➡️ Clicking Display Results button..."
        display_button = slow_wait.until do
          el = crawler.find_element(:xpath, "//button[contains(., 'Display Results')]")
          el if el.displayed? && el.enabled?
        end
        crawler.execute_script("arguments[0].scrollIntoView(true);", display_button)
        crawler.action.move_to(display_button).click.perform

        # Wait a moment for results to render
        sleep 1

        # Conditional: check if real results exist
        results_present = begin
          slow_wait.until do
            crawler.find_element(:css, ".leftJustifyStyle + table") # adjust to actual results table container
          end
          true
        rescue Selenium::WebDriver::Error::TimeoutError
          false
        end

        if results_present
          puts "➡️ Real results found, clicking Details button..."
          detail_button = slow_wait.until do
            el = crawler.find_element(:xpath, "//button[contains(., 'Details')]")
            el if el.displayed? && el.enabled?
          end
          crawler.execute_script("arguments[0].scrollIntoView(true);", detail_button)
          crawler.action.move_to(detail_button).click.perform

          puts "⏳ Waiting for redirect..."
          wait_for_redirect
        else
          puts "⚠️ No real results found for #{@license_number}, skipping Details button"
        end

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
        puts "➡️ Closing browser..."
        crawler.quit if @crawler
      end

      private

      # Selenium headless browser with stable configuration
      def crawler
        return @crawler if @crawler

        Selenium::WebDriver.logger.level = :error
        client = Selenium::WebDriver::Remote::Http::Default.new
        client.read_timeout = 120
        client.open_timeout = 40

        @crawler = Selenium::WebDriver.for(
          :chrome,
          options: chrome_options,
          http_client: client
        )
      end

      def chrome_options
        opts = Selenium::WebDriver::Chrome::Options.new
        opts.add_argument("--headless=new")
        opts.add_argument("--disable-gpu")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--window-size=1600,2500")
        opts.add_argument("--dns-prefetch-disable")
        opts.add_argument("--disable-background-networking")
        opts.add_argument("--disable-software-rasterizer")
        opts.add_argument("--disable-renderer-backgrounding")
        opts.add_argument("--disable-infobars")
        opts.add_argument("--disable-extensions")
        opts.add_argument("--ignore-certificate-errors")
        opts.add_argument("--disable-popup-blocking")
        opts.add_argument("--remote-allow-origins=*")
        opts.add_argument("--disable-features=IsolateOrigins,site-per-process")
        opts.add_argument("--disable-site-isolation-trials")
        opts.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 4)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      def wait_for_redirect
        slow_wait.until { crawler.current_url.include?('LicenseVerification') }
      rescue
        puts "⚠️ Verification page load timeout"
      end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)
        filename = "#{@state.name}_#{@license_number}.png"
        path = dir.join(filename).to_s
        crawler.save_screenshot(path)
        "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"
      end
    end
  end
end

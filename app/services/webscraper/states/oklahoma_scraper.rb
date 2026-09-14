require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class OklahomaScraper
      SEARCH_URL = "https://pay.apps.ok.gov/OSBEP/_app/search/index.php".freeze

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
        enter_license_number

        puts "➡️ Clicking search button..."
        click_search

        puts "⏳ Waiting for results table..."
        wait_for_results_table

        puts "➡️ Clicking license result link..."
        click_result_link

        puts "⏳ Waiting for detail page..."
        wait_for_detail_page

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
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
        opts.add_argument("--window-size=1400,2000")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 4)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 15)
      end

      def enter_license_number
        # License Number field on OK psychologist search
        input = fast_wait.until { crawler.find_element(:id, "LICENSE_NUM") }
        input.clear
        input.send_keys(@license_number)
      end

      def click_search
        search_button = fast_wait.until {
          crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
        }
        search_button.click
      end

      def wait_for_results_table
        slow_wait.until do
          # Results table with id="psychologists"
          crawler.find_elements(:id, "psychologists").any?
        end
      end

      def click_result_link
        # First result link inside the results table
        link = slow_wait.until do
          crawler.find_element(
            :xpath,
            "//table[@id='psychologists']//tbody//tr[1]//td[1]//a[contains(@href,'psychologist.php?id=')]"
          )
        end
        crawler.execute_script("arguments[0].click();", link)
      end

      def wait_for_detail_page
        slow_wait.until do
          url = crawler.current_url
          html = crawler.page_source
          url.include?("psychologist.php?id=") && html.include?("License Info")
        end
      end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        crawler.save_screenshot(path)

        Rails.logger.info("✅ Screenshot saved at: #{public_url}")

        human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")
        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "SouthEast"
          c.fill "white"
          c.pointsize 16
          c.draw "text 30,10 '#{human_date}'"
        end
        image.write(path)

        public_url
      end
    end
  end
end

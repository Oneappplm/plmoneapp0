require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class TexasScraper
      # SEARCH_URL = "https://tob.texas.gov/licensesearch/".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url
      end

      # Entry point
      def call
        crawl!
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        puts "➡️ Entering license number..."
        crawler.find_element(:id, 'lic_nbr')
               .send_keys(@license_number)

        puts "➡️ Clicking search button..."
        fast_wait.until {
          crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
        }.click

        puts "⏳ Waiting for results table..."
        wait_for_results_table

        puts "➡️ Checking for detail link..."
        if click_detail_link
          puts "➡️ Detail page opened successfully."
        else
          puts "⚠️ No detail link found. Saving result page instead..."
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

      ##############################################
      # GLOBAL SELENIUM CORE (same for all scrapers)
      ##############################################

      def crawler
        @crawler ||= Selenium::WebDriver.for(:chrome, options: chrome_options)
      end

      def chrome_options
        opts = Selenium::WebDriver::Chrome::Options.new
        opts.add_argument("--headless=new")
        opts.add_argument("--disable-gpu")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--window-size=1400,2400")
        opts.add_argument("--disable-blink-features=AutomationControlled")
        opts.add_argument("--remote-allow-origins=*")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 4)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 15)
      end

      ##############################################
      # PAGE LOGIC
      ##############################################

      # Wait for the results table or "no results" message
      def wait_for_results_table
        slow_wait.until do
          crawler.find_elements(:css, "table").any? ||
          crawler.page_source.include?("No records found") ||
          crawler.page_source.include?("No results")
        end
      rescue Selenium::WebDriver::Error::TimeoutError
        puts "⚠️ Timeout waiting for table, continuing anyway..."
      end

      # Click the table row detail link if present
      def click_detail_link
        begin
          link = slow_wait.until do
            elems = crawler.find_elements(:xpath, "//table//td/a[contains(@href,'dts-zoom.php?id')]")
            elems.first if elems.any?
          end

          puts "➡️ Clicking detail link: #{link.attribute('href')}"
          link.click
          true
        rescue Selenium::WebDriver::Error::TimeoutError
          false
        rescue => e
          puts "⚠️ Could not click detail link: #{e.message}"
          false
        end
      end

      ##############################################
      # SCREENSHOT
      ##############################################

      # def save_screenshot
      #   dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
      #   FileUtils.mkdir_p(dir)

      #   file_name = "#{@state.name}_#{@license_number}.png"
      #   full_path = dir.join(file_name).to_s

      #   crawler.save_screenshot(full_path)

      #   # Public-facing URL
      #   "/webscrape/Licensure/#{@state.alpha_code}/#{file_name}"
      # end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "#{@state.name}_#{@license_number}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        # 1️⃣ Take raw screenshot
        crawler.save_screenshot(path)

        # 2️⃣ Add timestamp
        human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "NorthWest"          # top-left as origin
          c.fill "black"
          c.pointsize 14
          c.draw "text 100,1220 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

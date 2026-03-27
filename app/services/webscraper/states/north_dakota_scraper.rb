require "selenium-webdriver"
require "fileutils"
require "mini_magick"
require "selenium/webdriver/support/select"

module Webscraper
  module States
    class NorthDakotaScraper

      SEARCH_URL = "https://www.ndpodiatryboard.org/podiatrists/".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url
      end

      def call
        raise "License search URL missing for #{@state.name}" if @url.blank?
        crawl!
      end

      def crawl!
        puts "➡️ Opening #{@state.name} site..."
        crawler.get(@url)

        puts "➡️ Selecting License # from dropdown..."
        select_license_dropdown

        puts "➡️ Entering license number..."
        enter_license_number

        puts "➡️ Clicking search button..."
        click_search

        puts "⏳ Waiting for results..."
        wait_for_results

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

      def select_license_dropdown
        dropdown = fast_wait.until { crawler.find_element(:id, "pdb-search_field-2") }
        select = Selenium::WebDriver::Support::Select.new(dropdown)
        select.select_by(:value, "license_number")
        puts "✅ License # selected"
      end

      def enter_license_number
        input = fast_wait.until { crawler.find_element(:id, "participant_search_term") }
        input.clear
        input.send_keys(@license_number)
        puts "✅ License '#{@license_number}' entered"
      end

      def click_search
        search_button = fast_wait.until {
          crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
        }
        crawler.execute_script("arguments[0].click();", search_button)  # JS click for AJAX forms
        puts "✅ Search clicked"
      end

      def wait_for_results
        sleep 3  # Fixed wait for AJAX to complete
        
        slow_wait.until do
          page_source = crawler.page_source
          # Look for results indicators
          page_source.include?(@license_number) ||  
          page_source.include?("License Status") || 
          page_source.match?(/No records|No results|No matches/i) ||
          # Or table rows changed (results loaded)
          crawler.find_elements(:xpath, "//table//tr").size > 5
        end
        puts "✅ Results page loaded"
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
          c.fill "black"
          c.pointsize 14
          c.draw "text 30,10 '#{human_date}'"
        end
        image.write(path)

        public_url
      end
    end
  end
end

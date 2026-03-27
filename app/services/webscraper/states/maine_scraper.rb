require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class MaineScraper
      SEARCH_URL = "https://www.pfr.maine.gov/almsonline/almsquery/SearchCompany.aspx".freeze

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

        select_regulator_all
        wait_for_regulator_postback

        enter_license_number
        click_search
        wait_for_results_table
        open_first_result

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
        opts.add_argument("--window-size=1600,2400")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 4)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      def select_regulator_all
        puts "➡️ Selecting Regulator = ALL..."
        select_el = fast_wait.until { crawler.find_element(:id, "scRegulator") }
        Selenium::WebDriver::Support::Select.new(select_el).select_by(:text, "ALL")
      end

      def wait_for_regulator_postback
        puts "⏳ Waiting for regulator postback..."
        sleep 2 
      end

      def enter_license_number
        puts "➡️ Entering license number..."
        input = fast_wait.until { crawler.find_element(:id, "scLicenseNo") }
        input.clear
        input.send_keys(@license_number)
      end

      def click_search
        puts "➡️ Clicking Search..."
        btn = fast_wait.until { crawler.find_element(:id, "btnSearch") }
        crawler.execute_script("arguments[0].click();", btn)
      end

      def wait_for_results_table
        puts "⏳ Waiting for search results..."
        slow_wait.until do
          html = crawler.page_source
          html.include?("gvLicensees") || html.include?("No records found")
        end
      end

      def open_first_result
        puts "➡️ Opening first result..."
        link = slow_wait.until do
          crawler.find_element(:css, "#gvLicensees tbody tr a")
        end
        crawler.execute_script("arguments[0].click();", link)
        slow_wait.until { !crawler.current_url.include?("SearchCompany.aspx") }
      end

      # Wait for search results to appear
      def wait_for_results_table
        30.times do
          html = crawler.page_source

          # Case 1: has results
          return true if html.include?("usLicenseList_gvResults")

          # Case 2: no results
          if html.include?("No records found") ||
             html.include?("No individuals match")
            puts "⚠️ No results found for this license"
            return true
          end

          sleep 1
        end

        puts "⚠️ Results table timeout."
        true
      end

      # Click Format for Print
      def click_format_for_print
        print_button = nil

        20.times do
          begin
            btn = crawler.find_element(:id, "usLicenseList_btnPrint")
            if btn.displayed?
              print_button = btn
              break
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
            # ignore and retry
          end
          sleep 0.5
        end

        if print_button
          crawler.execute_script("arguments[0].click();", print_button)
        else
          puts "⚠️ Print button not found — continuing anyway"
        end
      end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "#{@state.name}_#{@license_number}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        # 1️⃣ Take raw screenshot
        crawler.save_screenshot(path)

        # 2️⃣ Add timestamp (e.g. "2025-12-18")
        human_date = Time.current.in_time_zone('Pacific Time (US & Canada)').strftime('%Y-%m-%d, %I:%M %p')

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "SouthEast"         
          c.fill "black"
          c.pointsize 14
          c.draw "text 30,10 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

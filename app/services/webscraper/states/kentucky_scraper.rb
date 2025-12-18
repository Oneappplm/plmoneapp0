require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class KentuckyScraper
      SEARCH_URL = "http://web1.ky.gov/GenSearch/LicenseSearch.aspx?AGY=5".freeze

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

        # --- Enter license number ---
        puts "➡️ Entering license number..."
        input = fast_wait.until {
          crawler.find_element(:id, "usLicenseSearch_txtField2")
        }
        input.clear
        input.send_keys(@license_number)

        # --- Click Search button ---
        puts "➡️ Clicking search button..."
        search_button = fast_wait.until {
          crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
        }
        crawler.execute_script("arguments[0].click();", search_button)

        # --- Wait for results table ---
        puts "⏳ Waiting for search results..."
        wait_for_results_table

        # --- Click Format for Print button ---
        puts "➡️ Clicking 'Format for Print'..."
        click_format_for_print

        # --- Screenshot ---
        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path

      rescue => e
        puts "❌ Error: #{e.message}"
        raise e
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

      # Save Screenshot
      # def save_screenshot
      #   dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
      #   FileUtils.mkdir_p(dir)

      #   file_name = "#{@state.name}_#{@license_number}.png"
      #   full_path = dir.join(file_name).to_s

      #   crawler.save_screenshot(full_path)

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

        # 2️⃣ Add timestamp (e.g. "2025-12-18")
        human_date = Time.current.strftime("%Y-%m-%d")

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "NorthEast"          # top-left as origin
          c.fill "black"
          c.pointsize 14
          c.draw "text 30,70 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

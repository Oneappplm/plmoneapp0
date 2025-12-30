require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class PennsylvaniaScraper
      
      # SEARCH_URL = "https://www.pals.pa.gov/#!/page/search"

      def initialize(license_number, state)
        @license_number = license_number.to_s.strip
        @state = state
        @url = state.license_search_url
      end

      def call
        raise "License search URL missing for #{@state.name}" if @url.blank?
        crawl!
      end

      def crawl!
        puts "➡️ Opening PA PALS..."
        crawler.get(@url)

        wait_for_search_form

        enter_license_number
        click_search

        wait_for_results_table
        open_license_details

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
        puts "➡️ Closing browser..."
        crawler.quit if @crawler
      end

      private

      # Selenium setup

      def crawler
        @crawler ||= Selenium::WebDriver.for(:chrome, options: chrome_options)
      end

      def chrome_options
        opts = Selenium::WebDriver::Chrome::Options.new
        opts.add_argument("--headless=new")
        opts.add_argument("--disable-gpu")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--window-size=1400,2200")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 10)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 25)
      end

      # Page actions

      def wait_for_search_form
        puts "➡️ Waiting for search form..."

        slow_wait.until do
          crawler.find_elements(:id, "LicenseNo").any?
        end
      end

      def enter_license_number
        puts "➡️ Entering license number..."

        input = fast_wait.until do
          el = crawler.find_element(:id, "LicenseNo")
          el if el.displayed? && el.enabled?
        end

        input.clear
        input.send_keys(@license_number)
      end

      def click_search
        puts "➡️ Clicking Search..."

        wait_for_overlay_to_disappear

        btn = fast_wait.until do
          el = crawler.find_element(:xpath, "//button[contains(., 'Search')]")
          el if el.displayed? && el.enabled?
        end

        crawler.execute_script("arguments[0].click();", btn)
      end


      def wait_for_results_table
        puts "⏳ Waiting for results table..."

        slow_wait.until do
          crawler.find_elements(:xpath, "//tbody/tr").any?
        end
      end

      def wait_for_overlay_to_disappear
        slow_wait.until do
          overlays = crawler.find_elements(:css, ".cg-busy")
          overlays.empty? || overlays.all? { |el| !el.displayed? }
        end
      end


      def open_license_details
        puts "➡️ Opening license details..."

        wait_for_overlay_to_disappear

        original_window = crawler.window_handle

        row = slow_wait.until do
          crawler.find_elements(
            :xpath,
            "//tbody/tr[td[contains(normalize-space(), '#{@license_number}')]]"
          ).first
        end
        raise "❌ No results found for #{@license_number}" unless row

        link = row.find_element(:xpath, ".//a[contains(@ng-click, 'getAssetDetail')]")
        crawler.execute_script("arguments[0].scrollIntoView(true);", link)
        sleep 0.5
        crawler.execute_script("arguments[0].click();", link)

        # 🔹 hard wait 10 seconds for PA PALS to open detail window
        sleep 10

        # then proceed as before
        slow_wait.until { crawler.window_handles.size > 1 }
        new_handle = (crawler.window_handles - [original_window]).first
        crawler.switch_to.window(new_handle)

        height = crawler.execute_script("return document.body.scrollHeight") rescue nil
        crawler.manage.window.resize_to(1400, height || 1200)

        slow_wait.until do
          src = crawler.page_source
          !src.empty? &&
            src.include?("Board/Commission:") &&
            src.include?("License Number:")
        end
      end

      # Screenshot

      # def save_screenshot
      #   dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
      #   FileUtils.mkdir_p(dir)

      #   filename = "#{@state.name}_#{@license_number}.png"
      #   path     = dir.join(filename).to_s

      #   height = crawler.execute_script("return document.body.scrollHeight")
      #   crawler.manage.window.resize_to(1400, height)

      #   crawler.save_screenshot(path)

      #   "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"
      # end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        # 1️⃣ Take raw screenshot
        crawler.save_screenshot(path)

        Rails.logger.info("✅ Screenshot saved at: #{public_url}")

        # 2️⃣ Add timestamp (e.g. "2025-12-18")
        human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")

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

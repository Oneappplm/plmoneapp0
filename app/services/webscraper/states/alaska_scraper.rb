require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class AlaskaScraper
      SEARCH_URL = "https://www.commerce.alaska.gov/cbp/main/Search/Professional".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state = state
        @url = state.license_search_url || SEARCH_URL
      end

      def call
        raise "License number missing" if @license_number.blank?
        crawl!
      end

      def crawl!
        puts "➡️ Opening #{@state.name} site..."
        crawler.get(@url)

        wait_for_page

        puts "➡️ Entering license number..."
        enter_license_number

        puts "➡️ Clicking search..."
        click_search

        puts "⚠️ Waiting for CAPTCHA (manual or service)..."
        handle_captcha

        puts "➡️ Waiting for results table..."
        wait_for_results

        puts "➡️ Opening license details..."
        click_license_number

        puts "➡️ Clicking Print Friendly Version..."
        click_print_friendly

        puts "➡️ Wait for Print Page..."
        wait_for_print_page

        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot

        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
        puts "➡️ Closing browser..."
        crawler.quit if @crawler
      end

      private

      # ===============================
      # Selenium setup
      # ===============================
      def crawler
        @crawler ||= Selenium::WebDriver.for(:chrome, options: chrome_options)
      end

      def chrome_options
        opts = Selenium::WebDriver::Chrome::Options.new

        # ❗ Remove headless if solving CAPTCHA manually
        # opts.add_argument("--headless=new")

        opts.add_argument("--disable-gpu")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--window-size=1400,2000")
        opts
      end

      def wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      # ===============================
      # Page actions
      # ===============================
      def wait_for_page
        wait.until { crawler.execute_script("return document.readyState") == "complete" }
      end

      def enter_license_number
        input = wait.until do
          crawler.find_element(id: "LicenseNumber")
        end

        input.clear
        input.send_keys(@license_number)
      end

      def click_search
        search_btn = wait.until do
          crawler.find_element(id: "search")
        end

        crawler.execute_script("arguments[0].click();", search_btn)
      end

      # ===============================
      # CAPTCHA handling
      # ===============================
      def handle_captcha
        # Wait for captcha iframe
        wait.until do
          crawler.find_elements(css: "iframe[src*='recaptcha']").any?
        end

        puts "🧠 Please solve CAPTCHA manually in the browser..."

        # Wait until CAPTCHA iframe disappears (means solved)
        Selenium::WebDriver::Wait.new(timeout: 120).until do
          crawler.find_elements(css: "iframe[src*='recaptcha']").empty?
        end

        puts "✅ CAPTCHA solved"

        # click_continue_button
      end

      # def click_continue_button
      #   btn = wait.until do
      #     crawler.find_element(
      #       xpath: "//button[contains(.,'Continue') or contains(@class,'deptButton')]"
      #     )
      #   end

      #   crawler.execute_script("arguments[0].click();", btn)
      # end

      # ===============================
      # Results handling
      # ===============================
      def wait_for_results
        wait.until do
          crawler.find_elements(
            xpath: "//table[contains(@class,'deptGridView')]//a"
          ).any?
        end
      end

      def click_license_number
        license_link = wait.until do
          crawler.find_element(
            xpath: "//td[@data-th='License Number']//a"
          )
        end

        crawler.execute_script("arguments[0].click();", license_link)
      end

      def click_print_friendly
        original_window = crawler.window_handle
        existing_windows = crawler.window_handles

        print_btn = wait.until do
          crawler.find_element(
            xpath: "//a[contains(text(),'Print Friendly Version')]"
          )
        end

        crawler.execute_script("arguments[0].click();", print_btn)

        # Wait for new window
        wait.until do
          crawler.window_handles.size > existing_windows.size
        end

        new_window = (crawler.window_handles - existing_windows).first
        crawler.switch_to.window(new_window)

        puts "🪟 Switched to Print Friendly window"
      end

      def wait_for_print_page
        wait.until do
          crawler.execute_script("return document.readyState") == "complete" &&
            crawler.page_source.include?("License") ||
            crawler.find_elements(xpath: "//table").any?
        end
      end

      # ===============================
      # Screenshot
      # ===============================
      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        # ✅ Wait for Print Friendly to fully render
        wait_for_print_page
        sleep 1

        # ✅ Remove fixed headers (critical)
        crawler.execute_script <<~JS
          document.querySelectorAll('header, nav, .header, .navbar').forEach(e => e.remove());
          document.body.style.marginTop = '0px';
        JS

        # ✅ Scroll to top
        crawler.execute_script("window.scrollTo(0, 0);")
        sleep 0.5

        # ✅ Resize window to FULL document height
        height = crawler.execute_script("return document.body.scrollHeight")
        crawler.manage.window.resize_to(1400, height)

        # ✅ Final screenshot
        crawler.save_screenshot(path)

        add_timestamp(path)

        public_url
      end


      def add_timestamp(path)
        human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")

        image = MiniMagick::Image.open(path)
        image.combine_options do |c|
          c.gravity "SouthEast"
          c.fill "black"
          c.pointsize 14
          c.draw "text 30,10 '#{human_date}'"
        end
        image.write(path)
      end

      # ===============================
      # Anti-captcha placeholder
      # ===============================
      # def solve_captcha_with_service
      #   # Integrate 2Captcha / AntiCaptcha here
      # end
    end
  end
end

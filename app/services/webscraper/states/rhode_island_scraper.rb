require "selenium-webdriver"
require "fileutils"

module Webscraper
  module States
    class RhodeIslandScraper
      SEARCH_URL = "https://healthri.mylicense.com/Verification/".freeze

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

        # --- Step 1: Switch to iframe if exists ---
        iframe = nil
        15.times do
          begin
            frames = crawler.find_elements(:tag_name, "iframe")
            if frames.any?
              iframe = frames.first
              crawler.switch_to.frame(iframe)
              puts "➡️ Switched to iframe..."
              break
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
            # retry silently
          end
          sleep 1
        end

        puts "⚠️ No iframe found, using main page" unless iframe

        # --- Step 2: Find license input field ---
        license_input = nil
        20.times do
          begin
            el = crawler.find_element(:id, "t_web_lookup__license_no")
            if el.displayed?
              license_input = el
              break
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
          end
          sleep 1
        end
        raise "License input not found" unless license_input

        license_input.clear
        license_input.send_keys(@license_number)

        # --- Step 3: Click 'Verify' button ---
        verify_btn = nil
        15.times do
          begin
            btn = crawler.find_element(:id, "sch_button")
            if btn.displayed?
              verify_btn = btn
              break
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
          end
          sleep 1
        end
        raise "Verify button not found" unless verify_btn
        verify_btn.click

        # --- Step 4: Wait for search results page to load ---
        wait_for_redirect

        # --- Step 5: Click the first license result ---
        result_link = nil
        30.times do
          begin
            link = crawler.find_element(:xpath, "//a[contains(@id,'hl')][1]")
            if link.displayed?
              result_link = link
              break
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
          end
          sleep 1
        end
        raise "License result link not found" unless result_link

        # Scroll and click using JS to avoid stale element issues
        crawler.execute_script("arguments[0].scrollIntoView(true);", result_link)
        crawler.execute_script("arguments[0].click();", result_link)

        # --- Step 6: Switch to new window/tab ---
        new_window = nil
        20.times do
          if crawler.window_handles.size > 1
            new_window = (crawler.window_handles - [crawler.window_handle]).first
            crawler.switch_to.window(new_window)
            puts "➡️ Switched to result tab"
            break
          end
          sleep 1
        end
        raise "New result window did not open" unless new_window

        # --- Step 7: Wait for details page to load ---
        20.times do
          break if crawler.find_elements(:tag_name, "body").any?
          sleep 1
        end

        # --- Step 8: Save screenshot ---
        puts "➡️ Saving screenshot..."
        screenshot_path = save_screenshot
        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path

      rescue => e
        puts "❌ Error during crawl: #{e.message}"
        raise e
      ensure
        puts "➡️ Closing browser..."
        crawler.quit if @crawler
      end

      private

      # Selenium headless browser
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
        Selenium::WebDriver::Wait.new(timeout: 15)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 30)
      end

      def wait_for_redirect
        slow_wait.until { crawler.current_url.include?('LicenseVerification') }
      rescue
        puts "⚠️ Redirect timeout reached"
      end

      # def save_screenshot
      #   dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
      #   FileUtils.mkdir_p(dir)

      #   filename = "#{@state.name}_#{@license_number}.png"
      #   path = dir.join(filename).to_s
      #   crawler.save_screenshot(path)

      #   # Return URL accessible via browser
      #   "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"
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
          c.gravity "NorthWest"        # top center
          c.fill "black"             
          c.pointsize 14           
          # x offset = 0 (centered), y offset ~ 520px from top (tweak this)
          c.draw "text 50,298 '#{human_date}'"
        end
        image.write(path)

        # 3️⃣ Return URL accessible via browser
        public_url
      end
    end
  end
end

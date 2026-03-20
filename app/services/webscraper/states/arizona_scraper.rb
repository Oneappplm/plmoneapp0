module Webscraper
  module States
    class ArizonaScraper
      SEARCH_URL = "https://azus-sbde.ongovcore.com/public/verify-professional-license".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state          = state
        @url            = state.license_search_url || SEARCH_URL
      end

      def call
        raise "License number missing" if @license_number.blank?

        crawl!
      end

      def crawl!
        puts "➡️ Opening #{@state.name} site..."
        crawler.get(@url)

        sleep 2

        # Enter license + search
        enter_license_number
        click_search

        # Wait for results
        wait_for_results

        # Click "View"
        click_view_button

        # Wait a bit for details to load
        sleep 1

        # Trigger print (we don’t actually print, just treat page as ready)
        trigger_print_button

        # Take screenshot
        sleep 2
        final_screenshot = Rails.root.join("tmp", "arizona_final.png")
        crawler.save_screenshot(final_screenshot)
        puts "📸 Final screenshot: #{final_screenshot}"

        screenshot_path = save_screenshot
        puts "✅ Screenshot saved at: #{screenshot_path}"
        screenshot_path
      ensure
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
        opts.add_argument("--no-sandbox")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--window-size=1400,1000")

        # Make it look more like a real browser
        opts.add_argument("--disable-blink-features=AutomationControlled")
        opts.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36")

        opts
      end

      def wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      def enter_license_number
        input_selector = "input[name='keywords']"

        input = wait.until { crawler.find_element(:css, input_selector) }
        input.clear
        input.send_keys(@license_number)
        puts "✅ License '#{@license_number}' entered in keywords field"
      end

      def click_search
        search_btn_selector = "button.btn.btn-brand[type='submit']"

        search_btn = wait.until { crawler.find_element(:css, search_btn_selector) }
        # Use JS click to avoid Angular timing issues
        crawler.execute_script("arguments[0].click();", search_btn)
        puts "✅ Search button clicked"
      end

      def wait_for_results
        puts "⏳ Waiting for results..."

        wait.until do
          page_source = crawler.page_source
          page_source.include?(@license_number) ||
            page_source.match?(/no results|no records|no matches/i) ||
            crawler.find_elements(:css, "table").any? ||
            crawler.find_elements(:css, ".license-details").any?
        end
        puts "✅ Results loaded"
      end

      def click_view_button
        view_btn = wait.until do
          crawler.find_elements(:xpath, "//span[contains(text(),'View')]").first
        end

        crawler.execute_script("arguments[0].click();", view_btn)
        puts "✅ View button clicked"
      end

      def trigger_print_button
        print_btn_selector = "a[href='javascript:window.print();']"

        print_btn = wait.until { crawler.find_element(:css, print_btn_selector) }
        crawler.execute_script("arguments[0].click();", print_btn)
        puts "✅ Print button triggered (window.print called)"
      end

      def save_screenshot
       dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        result = crawler.execute_cdp(
          "Page.captureScreenshot",
          captureBeyondViewport: true,
          fromSurface: true
        )

        File.open(path, "wb") do |f|
          f.write(Base64.decode64(result["data"]))
        end

        human_date = Time.now
          .in_time_zone('Pacific Time (US & Canada)')
          .strftime("%Y-%m-%d, %I:%M %p")

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

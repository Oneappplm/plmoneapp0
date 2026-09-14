require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class MissouriScraper
      
      SEARCH_URL = "https://pr.mo.gov/licensee-search-division.asp".freeze

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
        puts "➡️ Opening site..."
        crawler.get(@url)

        debug_path = Rails.root.join("tmp", "missouri_initial_page.png")
        crawler.save_screenshot(debug_path)
        puts "📸 Debug screenshot: #{debug_path}"

        sleep 2 # Let JS fully render


        puts "➡️ Selecting License Number radio..."
        select_license_radio

        sleep 1 

        puts "➡️ Entering license number..."
        enter_license_number

        puts "➡️ Clicking Submit..."
        click_submit

        puts "⏳ Waiting for results..."
        wait_for_results

        puts "➡️ Clicking eye icon..."
        click_eye_icon

        puts "⏳ Waiting for detail view..."
        wait_for_detail_view

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

      def select_license_radio
        # Use the label text, then click the label (LWC will handle the radio)
        label_xpath = "//label[contains(@class,'slds-radio__label') and contains(., 'License Number (Exact')]"
        label = slow_wait.until { crawler.find_element(:xpath, label_xpath) }
        crawler.execute_script("arguments[0].click();", label)
        puts "✅ License radio selected by clicking label"
      end

      def enter_license_number
        # 1️⃣ Click the visible input container to focus the real field
        container_xpath = "//div[contains(@class,'slds-form-element__control') and @part='input-container']"
        container = slow_wait.until { crawler.find_element(:xpath, container_xpath) }
        crawler.execute_script("arguments[0].scrollIntoView(true);", container)
        crawler.execute_script("arguments[0].click();", container)
        sleep 0.5

        # 2️⃣ Now grab the active element (the actual Lightning input) and type into it via JS
        active = crawler.switch_to.active_element
        puts "✅ Active element tag: #{active.tag_name}, id: #{active.attribute('id')}"

        crawler.execute_script("
          arguments[0].value = '';
          arguments[0].dispatchEvent(new Event('input', {bubbles: true}));
          arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
        ", active)

        crawler.execute_script("
          arguments[0].value = '#{@license_number}';
          arguments[0].dispatchEvent(new Event('input', {bubbles: true}));
          arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
        ", active)

        sleep 0.5
        puts "✅ License '#{@license_number}' entered into active element"
      end

      def click_submit
        submit_xpath = "//button[contains(@class,'slds-button_brand') and @title='Submit']"
        btn = slow_wait.until { crawler.find_element(:xpath, submit_xpath) }
        crawler.execute_script("arguments[0].click();", btn)
        puts "✅ Submit clicked"
      end

      def wait_for_results
        # Wait until at least one result row with a view icon is rendered
        slow_wait.until do
          src = crawler.page_source
          # Any of these suggest results loaded
          src.include?("aria-label=\"View") ||  # lightning-button aria-label
            src.include?("data-id=\"") ||      # your lightning-button data-id
            crawler.find_elements(:xpath, "//lightning-button").size > 0
        end
        puts "✅ Results appear to be loaded"
      end

      def click_eye_icon
        js = <<~JS
          const host = document.querySelector('c-mo-dpr-license-search');
          if (!host || !host.shadowRoot) { return { status: 'NO_HOST' }; }

          // Debug: log what we see in the shadow root
          const root = host.shadowRoot;
          const tables = Array.from(root.querySelectorAll('table'));
          const licenseTables = tables.filter(t => t.className.includes('licensee-table'));
          const allButtons = Array.from(root.querySelectorAll('button'));
          const viewButtons = allButtons.filter(b =>
            (b.title && b.title.toLowerCase() === 'view') ||
            (b.getAttribute('aria-label') || '').startsWith('View')
          );

          // Try very specific selector based on your HTML
          let btn = root.querySelector(
            "table.licensee-table tbody tr:first-child td:last-child lightning-button button[title='view']"
          );
          if (!btn) {
            // Fallback: any view button inside licensee-table
            btn = root.querySelector("table.licensee-table button[title='view'], table.licensee-table button[aria-label^='View']");
          }
          if (!btn) {
            // Fallback: any button with preview icon anywhere under component
            btn = root.querySelector("button[title='view'], button[aria-label^='View'], lightning-button[variant='neutral'] button");
          }
          if (!btn && viewButtons.length > 0) {
            btn = viewButtons[0];
          }

          if (!btn) {
            return {
              status: 'NO_BUTTON',
              tables: tables.map(t => t.className),
              licenseTables: licenseTables.map(t => t.className),
              buttonCount: allButtons.length,
              viewButtonCount: viewButtons.length
            };
          }

          btn.scrollIntoView({ block: 'center' });
          btn.click();
          return {
            status: 'CLICKED',
            tables: tables.map(t => t.className),
            licenseTables: licenseTables.map(t => t.className),
            buttonTag: btn.tagName,
            buttonTitle: btn.title,
            buttonAria: btn.getAttribute('aria-label')
          };
        JS

        result = crawler.execute_script(js)
        puts "🔎 click_eye_icon JS result: #{result.inspect}"

        raise "❌ No eye/view button found (#{result['status']})" unless result['status'] == 'CLICKED'

        puts "✅ Eye icon clicked"
      end


      def wait_for_detail_view
        slow_wait.until {
          page_source = crawler.page_source
          # Detail loaded (no spinner, has license content)
          page_source.include?(@license_number) ||
          !page_source.match?(/loading|spinner/i)
        }
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

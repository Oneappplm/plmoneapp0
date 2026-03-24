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

        sleep 2

        puts "➡️ Selecting License Number radio..."
        select_license_radio

        sleep 1 

        puts "➡️ Entering license number..."
        enter_license_number

        puts "➡️ Clicking Submit..."
        click_submit

        sleep 2

        puts "⏳ Waiting for results..."
        wait_for_results

        puts "Clicking on eye icon..."
        click_eye_icon

        sleep 2

        # 👈 TAKE SCREENSHOT OF RESULTS PAGE INSTEAD
        puts "➡️ Saving RESULTS screenshot (no detail view needed)..."
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
        puts "⏳ Searching input across ALL shadow DOM..."

        input = slow_wait.until do
          el = crawler.execute_script(<<~JS)
            function findInput(root) {
              if (!root) return null;

              // Check current level
              const input = root.querySelector && root.querySelector("input.slds-input");
              if (input) return input;

              // Traverse children
              const elements = root.querySelectorAll ? root.querySelectorAll("*") : [];
              for (let el of elements) {
                if (el.shadowRoot) {
                  const found = findInput(el.shadowRoot);
                  if (found) return found;
                }
              }

              return null;
            }

            return findInput(document);
          JS

          el
        end

        raise "❌ Input not found anywhere in DOM" unless input

        puts "➡️ Input found, typing license..."

        input.click
        sleep 0.5

        # Clear
        input.clear rescue nil

        # Type like real user
        input.send_keys(@license_number)

        sleep 1

        # DEBUG
        value = crawler.execute_script("return arguments[0].value", input)
        puts "🔎 Input value after typing: #{value}"

        raise "❌ Value NOT entered" if value.blank?

        puts "✅ License entered successfully"
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
        puts "⏳ Waiting for eye icon to appear inside shadow DOM..."

        # More flexible timeout + multiple selectors
        slow_wait = Selenium::WebDriver::Wait.new(timeout: 25)  # Increased to 25s
        
        result = slow_wait.until do
          crawler.execute_script(<<~JS)
            const host = document.querySelector('c-mo-dpr-license-search');
            if (!host || !host.shadowRoot) return { status: 'NO_HOST' };

            const lightningBtns = host.shadowRoot.querySelectorAll("lightning-button, [data-id], button");

            for (let btn of lightningBtns) {
              if (!btn.shadowRoot && !btn.click) continue;

              // Try shadowRoot first, then direct element
              let targetBtn = btn.shadowRoot ? btn.shadowRoot.querySelector("button") : btn;
              
              if (targetBtn && targetBtn.click && (
                targetBtn.title?.toLowerCase().includes('view') ||
                targetBtn.getAttribute("aria-label")?.toLowerCase().includes('view') ||
                targetBtn.textContent?.toLowerCase().includes('view') ||
                targetBtn.getAttribute('data-id')  // Any button with data-id
              )) {
                targetBtn.scrollIntoView({ block: 'center', behavior: 'smooth' });
                targetBtn.click();
                
                return {
                  status: 'CLICKED',
                  selector: targetBtn.tagName,
                  title: targetBtn.title || targetBtn.getAttribute("aria-label"),
                  dataId: targetBtn.getAttribute('data-id')
                };
              }
            }

            // Fallback: click FIRST lightning-button or ANY view-like button
            const firstBtn = host.shadowRoot.querySelector("lightning-button button, button[data-id]");
            if (firstBtn) {
              firstBtn.click();
              return { status: 'FALLBACK_CLICKED', selector: firstBtn.tagName };
            }

            return { status: 'NO_BUTTON_FOUND' };
          JS
        end

        puts "✅ Eye icon clicked: #{result.inspect}"
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

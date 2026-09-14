require "selenium-webdriver"
require "fileutils"
require "mini_magick"
require "selenium/webdriver/support/select"

module Webscraper
  module States
    class AlabamaScraper

      SEARCH_URL = "https://alsbm.org/midwives/".freeze

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

        wait_for_cloudflare

        # Multiple debug screenshots
        debug1 = Rails.root.join("tmp", "alabama_cf1.png")
        crawler.save_screenshot(debug1)
        puts "📸 1. After Cloudflare: #{debug1}"

        sleep 5  # Let JS settle
        debug2 = Rails.root.join("tmp", "alabama_cf2_5s.png")
        crawler.save_screenshot(debug2)
        puts "📸 2. After 5s: #{debug2}"

        sleep 5  # Total 10s
        debug3 = Rails.root.join("tmp", "alabama_cf3_10s.png")
        crawler.save_screenshot(debug3)
        puts "📸 3. After 10s: #{debug3}"

        # Log page structure
        structure = crawler.execute_script <<~JS
          return {
            title: document.title,
            forms: Array.from(document.forms).map(f => ({id: f.id, elements: Array.from(f.elements).map(e => ({tag: e.tagName, type: e.type, id: e.id, name: e.name}))})),
            selects: Array.from(document.querySelectorAll('select')).map(s => ({id: s.id, name: s.name})),
            inputs: Array.from(document.querySelectorAll('input[type="text"]')).map(i => ({id: i.id, name: i.name})),
            iframes: Array.from(document.querySelectorAll('iframe')).map(f => f.src)
          };
        JS
        puts "🔍 Page structure: #{structure.inspect}"

        # Try to find ANY form and interact
        form = crawler.find_elements(:tag_name, "form").first
        if form
          puts "✅ Found form with #{form.find_elements(:tag_name, "input").size} inputs"
          # Interact with first text input and submit button
          text_inputs = form.find_elements(:css, "input[type='text']")
          submit_btns = form.find_elements(:css, "input[type='submit']")
          
          if text_inputs.any?
            text_inputs.first.send_keys(@license_number)
            puts "✅ Entered license in first text input"
          end
          
          if submit_btns.any?
            submit_btns.first.click
            puts "✅ Clicked first submit button"
          end
        else
          puts "❌ No forms found"
        end

        sleep 5
        final_screenshot = Rails.root.join("tmp", "alabama_final.png")
        crawler.save_screenshot(final_screenshot)
        puts "📸 Final screenshot: #{final_screenshot}"

        # Save public screenshot
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
        # opts.add_argument("--headless=new")  # Keep off for debugging
        opts.add_argument("--disable-gpu")
        opts.add_argument("--no-sandbox")
        opts.add_argument("--disable-dev-shm-usage")
        opts.add_argument("--window-size=1400,2000")
        opts
      end

      def wait
        Selenium::WebDriver::Wait.new(timeout: 20)
      end

      def wait_for_cloudflare
        puts "🛑 Cloudflare detected"
        Selenium::WebDriver::Wait.new(timeout: 180).until do
          !crawler.page_source.include?("Verify you are human") &&
          !crawler.current_url.include?("/cdn-cgi/")
        end
        puts "✅ Cloudflare passed"
      end

      def wait_for_page
        wait.until { crawler.execute_script("return document.readyState") == "complete" }
      end

      def select_license_dropdown
        # Debug: log all selects
        selects = crawler.execute_script("return Array.from(document.querySelectorAll('select')).map(s => ({id: s.id, name: s.name, options: Array.from(s.options).map(o => o.textContent.trim())}));")
        puts "📋 Found #{selects.length} selects: #{selects.inspect}"

        # Try to find License dropdown
        dropdown = nil
        dropdown_selectors = [
          "select[name='search_field']",
          "#pdb-search_field-2",
          "select option[contains(text(),'License')]"
        ]

        dropdown_selectors.each do |sel|
          begin
            dropdown = wait.until { crawler.find_element(:css, sel) }
            break
          rescue
          end
        end

        raise "No dropdown found - check screenshot" unless dropdown

        select = Selenium::WebDriver::Support::Select.new(dropdown)
        # Try License Number or similar
        select.select_by(:text, "License Number") rescue 
        select.select_by(:text, "License #") rescue 
        select.select_by(:value, "license_number") rescue 
        select.select_by(:index, 1)  # Usually second option after "(select)"
        
        puts "✅ License field selected"
      end

      def enter_license_number
        input_selectors = [
          "input[name='value']",
          "#participant_search_term",
          "input[type='text']"
        ]

        input = nil
        input_selectors.each do |sel|
          begin
            input = wait.until { crawler.find_element(:css, sel) }
            break
          rescue
          end
        end

        raise "No input field found - check screenshot" unless input

        input.clear
        input.send_keys(@license_number)
        puts "✅ License '#{@license_number}' entered"
      end

      def click_search
        search_selectors = [
          "input.search-form-submit",
          "input[type='submit'][value*='Search']",
          "input[type='submit']"
        ]

        search_btn = nil
        search_selectors.each do |sel|
          begin
            search_btn = wait.until { crawler.find_element(:css, sel) }
            break
          rescue
          end
        end

        raise "No search button found" unless search_btn

        crawler.execute_script("arguments[0].click();", search_btn)
        puts "✅ Search clicked"
      end

      def wait_for_results
        sleep 3
        
        wait.until do
          page_source = crawler.page_source
          page_source.include?(@license_number) ||
          page_source.match?(/no results|no records|no matches/i) ||
          crawler.find_elements(:css, "table").any?
        end
        puts "✅ Results loaded"
      end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        crawler.execute_script("window.scrollTo(0,0);")
        crawler.manage.window.maximize
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
    end
  end
end

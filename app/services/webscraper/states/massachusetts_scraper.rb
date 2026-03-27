require "selenium-webdriver"
require "fileutils"
require "mini_magick"

module Webscraper
  module States
    class MassachusettsScraper
      
      SEARCH_URL = "https://findmydoctor.mass.gov/".freeze

      def initialize(license_number, state)
        @license_number = license_number
        @state          = state
        @url            = state.license_search_url || SEARCH_URL
      end

      def call
        raise "License search URL missing for #{@state.name}" if @url.blank?
        crawl!
      end

      def crawl!
        puts "➡️ Opening site..."
        crawler.get(@url)

        select_license_type
        select_license_number_mode
        enter_license_number
        click_find_license
        open_licensee_profile

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
        opts.add_argument("--window-size=1400,2200")
        opts
      end

      def fast_wait
        Selenium::WebDriver::Wait.new(timeout: 8)
      end

      def slow_wait
        Selenium::WebDriver::Wait.new(timeout: 25)
      end

      # 1️⃣ select "Full Acupuncture License" in License Type
      def select_license_type
        puts "➡️ Selecting license type..."
        select_el = fast_wait.until do
          crawler.find_element(:id, "license-type-select")
        end

        select = Selenium::WebDriver::Support::Select.new(select_el)
        select.select_by(:text, "Full Acupuncture License")
      end

      # 2️⃣ choose "License Number" radio
      def select_license_number_mode
        puts "➡️ Selecting License Number mode..."
        radio = fast_wait.until do
          crawler.find_element(:id, "license-number")
        end
        crawler.execute_script("arguments[0].click();", radio)
      end

      # 3️⃣ enter license number
      def enter_license_number
        puts "➡️ Entering license number..."
        input = fast_wait.until do
          el = crawler.find_element(:id, "physician-license-number-input")
          el if el.displayed? && el.enabled?
        end
        input.clear
        input.send_keys(@license_number)
      end

      # 4️⃣ click "Find Licensee(s)"
      def click_find_license
        puts "➡️ Clicking Find Licensee(s)..."
        btn = fast_wait.until do
          el = crawler.find_element(:css, "button.search-button")
          el if el.displayed? && el.enabled?
        end
        crawler.execute_script("arguments[0].click();", btn)
      end

      # 5️⃣ click name link (opens new tab) and switch
      def open_licensee_profile
        puts "➡️ Opening licensee profile..."
        original_window = crawler.window_handle

        link = slow_wait.until do
          # first result row link
          crawler.find_element(:css, "hyperlink-cell-renderer a.page-link")
        end

        crawler.execute_script("arguments[0].scrollIntoView(true);", link)
        sleep 0.5
        crawler.execute_script("arguments[0].click();", link)

        # wait for new tab/window and switch to it [web:180][web:183]
        slow_wait.until { crawler.window_handles.size > 1 }
        new_handle = (crawler.window_handles - [original_window]).first
        crawler.switch_to.window(new_handle)

        # wait for profile page content
        slow_wait.until do
          src = crawler.page_source
          !src.empty? && src.include?("License Information")
        end
      end

      def save_screenshot
        dir = Rails.root.join("public", "webscrape", "Licensure", @state.alpha_code)
        FileUtils.mkdir_p(dir)

        filename   = "LICENSURE_#{@license_number}_#{@state.alpha_code}.png"
        path       = dir.join(filename).to_s
        public_url = "/webscrape/Licensure/#{@state.alpha_code}/#{filename}"

        height = crawler.execute_script("return document.body.scrollHeight") rescue 2000
        crawler.manage.window.resize_to(1400, height)

        crawler.save_screenshot(path)

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

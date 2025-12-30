require "selenium-webdriver"
require "fileutils"
require "mini_magick"

class Webscraper::NpiService
  SEARCH_URL = "https://npiregistry.cms.hhs.gov/search".freeze

  attr_reader :npi

  def initialize(npi)
    @npi = npi
  end

  def call
    crawl!
  end

  def crawl!
    puts "➡️ Opening site..."
    crawler.get(SEARCH_URL)

    # 1️⃣ Enter NPI number
    puts "1️⃣ Entering NPI number..."
    npi_input = retry_find(:id, "npiNumber")
    npi_input.clear
    npi_input.send_keys(npi)

    # 2️⃣ Click Search
    puts "2️⃣ Click Search"
    search_button = retry_find(:xpath, "//button[@type='submit' and normalize-space()='Search']")
    crawler.execute_script("arguments[0].click();", search_button)

    sleep 2

    # 3️⃣ Wait for results or "No results found"
    puts "3️⃣ Waiting for results..."
    max_attempts = 30
    attempts = 0
    loop do
      spinner_gone = begin
        s = crawler.find_element(:css, ".loading")
        !s.displayed?
      rescue Selenium::WebDriver::Error::NoSuchElementError
        true
      end

      table_exists = crawler.find_elements(:css, "table.table.table-striped.table-bordered").any?(&:displayed?)
      no_results = crawler.page_source.include?("No results found") ||
                   crawler.page_source.include?("No match found")

      break if spinner_gone && (table_exists || no_results)

      attempts += 1
      raise "Timed out waiting for results" if attempts >= max_attempts
      sleep 1
    end

    sleep 1 # allow Angular to render fully

    # 4️⃣ Take full-page screenshot
    save_screenshot

  rescue => e
    Rails.logger.error("❌ NPI lookup failed for #{npi}: #{e.message}")
    nil
  ensure
    crawler.quit if @crawler
  end

  private

  # Retry helper (waits up to 20s for element)
  def retry_find(by, selector, timeout: 20)
    attempts = 0
    interval = 0.5
    max_attempts = (timeout / interval).to_i

    loop do
      begin
        return crawler.find_element(by, selector)
      rescue Selenium::WebDriver::Error::NoSuchElementError
        attempts += 1
        raise "Element not found: #{selector}" if attempts >= max_attempts
        sleep interval
      end
    end
  end


  def save_screenshot
    base_path = Rails.root.join("public", "webscrape", "npi")
    FileUtils.mkdir_p(base_path)

    timestamp    = Time.now.to_i
    human_time   = Time.current.in_time_zone('Pacific Time (US & Canada)').strftime('%Y-%m-%d, %I:%M %p')
    png_path     = base_path.join("npi_#{npi}_#{timestamp}.png")
    final_path   = base_path.join("npi_#{npi}_#{timestamp}_ts.png") # with timestamp text

    # 🔹 Scroll to top
    crawler.execute_script("window.scrollTo(0, 0)")
    sleep 1

    # 🔹 Get full page height
    full_height = crawler.execute_script(
      "return Math.max(
        document.body.scrollHeight,
        document.documentElement.scrollHeight
      );"
    )

    # 🔹 Resize window to full height
    crawler.manage.window.resize_to(1400, full_height)
    sleep 1

    # 🔹 Take raw screenshot
    crawler.save_screenshot(png_path)
    raise "Screenshot failed" unless File.exist?(png_path)

    # 🔹 Add timestamp text using MiniMagick
    image = MiniMagick::Image.open(png_path.to_s)
    image.combine_options do |c|
      c.gravity "SouthEast"         
      c.fill "black"
      c.pointsize 16
      c.draw "text 10,10 '#{human_time}'"
    end
    image.write(final_path.to_s)

    # Optionally delete the raw screenshot without text
    File.delete(png_path) if File.exist?(png_path)

    # 🔹 Log to DB with final path
    WebcrawlerLog.create!(
      crawler_type: "NPI",
      filepath: final_path.relative_path_from(Rails.root).to_s,
      filetype: "png",
      status: "success"
    )

    final_path
  rescue => e
    WebcrawlerLog.create!(
      crawler_type: "NPI",
      status: "failed"
    )
    Rails.logger.error("❌ NPI screenshot failed: #{e.message}")
    nil
  end

  # ======================================================
  # 🚗 Selenium driver
  # ======================================================
  def crawler
    @crawler ||= begin
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--headless=new")
      options.add_argument("--disable-gpu")
      options.add_argument("--no-sandbox")
      options.add_argument("--window-size=1400,1200")

      Selenium::WebDriver.for(:chrome, options: options)
    end
  end
end

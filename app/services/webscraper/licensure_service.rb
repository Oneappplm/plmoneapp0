# frozen_string_literal: true
class Webscraper::LicensureService < WebscraperService
  attr_reader :license_number

  def initialize(license_number)
    @license_number = license_number
    @crawler_folder = 'Licensure'
  end

  def call
    crawl
  end

  def crawl!
    crawler.get('https://mqa-internet.doh.state.fl.us/mqasearchservices/healthcareproviders')

    crawler.find_element(:id, 'SearchDto_LicenseNumber').send_keys(license_number)

    # click search button with id  ctl00_cpExclusions_ibSearchSP
    search_button = wait.until { crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']") }
    search_button.click
    sleep(3)

   
    # Check if the search result page is loaded correctly
    if crawler.current_url.include?('LicenseVerification')
      puts "✅ Redirected to URL: #{crawler.current_url}"

      # Look for the 'Printer Friendly Version' link
      link = wait.until { crawler.find_element(:xpath, "//a[contains(., 'Printer Friendly Version')]") } rescue nil

      if link
        # Scroll into view and click using JavaScript
        crawler.execute_script("arguments[0].scrollIntoView();", link)
        sleep(1) # Small delay after scrolling
        crawler.execute_script("arguments[0].click();", link)
        sleep(5) # Allow PDF page to load
      else
        puts "❌ 'Printer Friendly Version' link not found."
      end
    else
      puts "❌ No redirect to LicenseVerification found after search."
    end

    webcrawler_log = save_screenshot

    sleep(2)
    crawler.quit()
  end

  private

  def wait
    Selenium::WebDriver::Wait.new(timeout: 10)
  end
end
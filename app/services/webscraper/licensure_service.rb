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
    puts "➡️ Opening site..."
    crawler.get('https://mqa-internet.doh.state.fl.us/mqasearchservices/healthcareproviders')

    puts "➡️ Entering license number..."
    crawler.find_element(:id, 'SearchDto_LicenseNumber').send_keys(license_number)

    puts "➡️ Clicking search button..."
    search_button = fast_wait.until { crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']") }
    search_button.click

    puts "⏳ Waiting for redirect..."
    wait_for_redirect

    if crawler.current_url.include?('LicenseVerification')
      puts "✅ Redirected successfully!"

      puts "➡️ Looking for printer-friendly link..."
      link = slow_wait.until { crawler.find_element(:xpath, "//a[contains(., 'Printer Friendly Version')]") } rescue nil

      if link
        puts "➡️ Clicking printer-friendly link..."
        crawler.execute_script("arguments[0].scrollIntoView();", link)
        crawler.execute_script("arguments[0].click();", link)
      else
        puts "❌ Printer-friendly link not found!"
      end
    else
      puts "❌ Not redirected to LicenseVerification page!"
    end

    puts "➡️ Saving screenshot..."
    webcrawler_log = save_screenshot

    puts "➡️ Closing browser..."
    crawler.quit

    webcrawler_log
  end

  private

  # Fast wait for buttons/elements that should appear quickly
  def fast_wait
    Selenium::WebDriver::Wait.new(timeout: 4)
  end

  # Slow wait for pages that load slowly (government websites)
  def slow_wait
    Selenium::WebDriver::Wait.new(timeout: 15)
  end

  def wait_for_redirect
    slow_wait.until do
      crawler.current_url.include?('LicenseVerification')
    end
  rescue
    puts "⚠️ Redirect timeout reached"
  end
end

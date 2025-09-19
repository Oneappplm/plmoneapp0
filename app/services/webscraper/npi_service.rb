# frozen_string_literal: true
class Webscraper::NpiService < WebscraperService
  attr_reader :npi

  def initialize(npi)
    @npi = npi
    @crawler_folder = 'Npi'
  end

  def call
    crawl!
  end

  def crawl!
    crawler.get('https://npiregistry.cms.hhs.gov/search')
    wait = Selenium::WebDriver::Wait.new(timeout: 20)

    wait.until { crawler.find_element(:id, 'npiNumber') }.send_keys(npi)

    search_button = wait.until { crawler.find_element(:css, "button[type='submit']") }
    crawler.execute_script("arguments[0].click();", search_button)
    sleep(1)
   
    # Wait for content to load by waiting for spinner to go or real data to appear
    wait.until do
      begin
        !crawler.find_element(css: '.loading').displayed?
      rescue Selenium::WebDriver::Error::NoSuchElementError
        true
      end
    end

    FileUtils.mkdir_p(Rails.root.join("public/webscrape/Npi"))
    screenshot_path = Rails.root.join("public/webscrape/Npi", "screenshot.png")

    crawler.save_screenshot(screenshot_path.to_s)
    crawler.quit
    
    {
      status: "match",
      message: "Scraping completed successfully!",
      screenshot_url: "/webscrape/Npi/screenshot.png"
    }
  end
end
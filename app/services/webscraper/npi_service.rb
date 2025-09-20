# frozen_string_literal: true
class Webscraper::NpiService < WebscraperService
  attr_reader :npi

  def initialize(npi)
    @npi = npi
    @crawler_folder = 'npi'
  end

  def call
    crawl!
  end

  def crawl!
    crawler.get('https://npiregistry.cms.hhs.gov/search')
    wait = Selenium::WebDriver::Wait.new(timeout: 20)

    # enter NPI
    wait.until { crawler.find_element(:id, 'npiNumber') }.send_keys(npi)

    # click search
    search_button = wait.until { crawler.find_element(:css, "button[type='submit']") }
    crawler.execute_script("arguments[0].click();", search_button)

    # wait for results to load
    wait.until do
      begin
        !crawler.find_element(css: '.loading').displayed?
      rescue Selenium::WebDriver::Error::NoSuchElementError
        true
      end
    end

    # use the same save_screenshot method as OIG
    webcrawler_log = save_screenshot

    sleep(2)
    crawler.quit
    webcrawler_log
  end
end

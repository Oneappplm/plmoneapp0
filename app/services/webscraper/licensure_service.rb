# frozen_string_literal: true
class Webscraper::LicensureService < WebscraperService
  attr_reader :last_name, :first_name, :license_number

  def initialize(last_name = 'emmet', first_name = '', license_number = '')
    @last_name = last_name
    @first_name = first_name
    @license_number = license_number
    @crawler_folder = 'licensure'
  end

  def call
    crawl!
  end

  def crawl!
    crawler.get('https://mqa-internet.doh.state.fl.us/mqasearchservices/healthcareproviders') # Replace with actual URL

    # Fill in last name, first name, and license number
    crawler.find_element(:id, 'SearchDto_LicenseNumber').send_keys(license_number)
    crawler.execute_script("document.getElementById('SearchDto_LicenseNumber').value = '#{license_number}';")

    # Click search button
    search_button = crawler.find_element(:xpath, "//input[@type='submit' and @value='Search']")
    search_button.click
    sleep(2)

    # Find results table
    table = crawler.find_element(:class, 'search_results') rescue nil

    if table.present?
      # Find row with matching license number
      row = table.find_element(xpath: "//tr[contains(., '#{license_number}')]")
      # Find link in row with text 'View Details'
      link = row.find_element(xpath: "//a[contains(., 'View Details')]")
      link.click
      sleep(2)
    end

    webcrawler_log = save_screenshot

    sleep(2)
    crawler.quit
  end
end

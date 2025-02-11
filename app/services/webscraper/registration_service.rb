# frozen_string_literal: true
class Webscraper::RegistrationService < WebscraperService
  attr_reader :last_name, :first_name

  def initialize(last_name = 'johnson', first_name = '')
    @last_name = last_name
    @first_name = first_name
    @crawler_folder = 'registration'
  end

  def call
    crawl
  end

  def crawl!
    crawler.get('https://exclusions.oig.hhs.gov/default.aspx') # <-- Replace with actual Registration website URL

    crawler.find_element(:id, 'registration_last_name').send_keys(last_name)
    crawler.find_element(:id, 'registration_first_name').send_keys(first_name)

    # Click search button (Replace with correct ID or Class)
    crawler.find_element(:id, 'registration_search_btn').click
    sleep(2)

    # Find table with class 'registration_results'
    table = crawler.find_element(:class, 'registration_results') rescue nil

    # If table is present, click 'Details' link
    if table.present?
      row = table.find_element(xpath: "//tr[contains(., '#{last_name.upcase}')]")
      link = row.find_element(xpath: "//a[contains(., 'Details')]") # Replace with actual text if needed
      link.click
      sleep(2)
    end

    webcrawler_log = save_screenshot

    sleep(2)
    crawler.quit()
  end
end

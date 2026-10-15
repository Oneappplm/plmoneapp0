# frozen_string_literal: true
class Webscraper::PalsVerificationService < WebscraperService
	attr_reader :license_number

	def initialize(license_number	= 'OS010089L')
		@license_number = license_number
		@crawler_folder = 'pals'
	end

	def call
		crawl
	end

	def crawl!
	  crawler.get('https://www.pals.pa.gov/')
	  wait = Selenium::WebDriver::Wait.new(timeout: 15)

	  wait.until { crawler.find_element(xpath: "//a[contains(., 'Person Search')]") }.click

	  wait.until { crawler.find_element(:id, 'LicenseNo') }.send_keys(license_number)

	  wait.until { crawler.find_element(xpath: "//button[@type='submit']") }.click

	  wait.until { crawler.find_element(:id, 'DataTables_Table_2') }

	  row = crawler.find_element(xpath: "//tr[contains(., '#{license_number}')]")
	  link = row.find_element(xpath: ".//a[contains(@ng-click, 'search')]")
	  link.click

	  sleep(5) # small delay before tab switch

	  # Switch to new tab if opened
		if crawler.window_handles.size > 1
		  crawler.switch_to.window(crawler.window_handles.last)
		end

		# Wait for content to load by waiting for spinner to go or real data to appear
		wait.until do
		  begin
		    !crawler.find_element(css: '.loading').displayed?
		  rescue Selenium::WebDriver::Error::NoSuchElementError
		    true
		  end
		end

		# Wait for real data (like a known field or section)
		wait.until { crawler.find_element(xpath: "//div[contains(@class, 'panel-heading') and contains(., 'License')]") }

		save_screenshot
		crawler.quit
	end
end

# frozen_string_literal: true
class Webscraper::PalsVerificationService < ApplicationService
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
		sleep(20)

		# find link with href href="#/page/search" and text 'Person Search'
		link = crawler.find_element(xpath: "//a[contains(., 'Person Search')]")
		link.click
		sleep(10)

		# find input with id 'LicenseNo' and set value to license_number
		input = crawler.find_element(:id, 'LicenseNo')
		input.send_keys(license_number)

		# find button with type 'submit' and click
		button = crawler.find_element(:xpath, "//button[@type='submit']")
		button.click
		sleep(5)

		# find table with id DataTables_Table_2
		table = crawler.find_element(:id, 'DataTables_Table_2')
		# find row with license_number
		row = table.find_element(xpath: "//tr[contains(., '#{license_number}')]")
		sleep(2)

		# find link in row with ng-click search.getAssetDetail(perDetails.LicenseNumber,perDetails.PersonId,perDetails.LicenseId)
		link = row.find_element(xpath: "//a[contains(@ng-click, 'search')]")
		link.click
		sleep(5)

		# find new page and move to the page
		crawler.switch_to.window(crawler.window_handles.last)
		sleep(3)

		save_screenshot

		sleep(2)
		crawler.quit()
	end
end

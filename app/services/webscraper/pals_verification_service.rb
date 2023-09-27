# frozen_string_literal: true
class Webscraper::PalsVerificationService < WebscraperService
	attr_reader :license_number

	def initialize(license_number	= 'OS010089L')
		@license_number = license_number
		@crawler_folder = 'pals'
	end

	def call
		# crawl
		if Rails.env.development?
			options = Selenium::WebDriver::Chrome::Options.new
		else
			Selenium::WebDriver::Chrome.path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
			options = Selenium::WebDriver::Chrome::Options.new(
					prefs: { 'profile.default_content_setting_values.notifications': 2 },
					binary: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
			)
		end

    # uncomment the following line to run headless else comment it out to run in browser
		options.add_argument('--headless')

		options.add_argument('--disable-gpu')
		options.add_argument('--no-sandbox')
		agent = Selenium::WebDriver.for :chrome, options: options

		agent.get('https://www.pals.pa.gov/')
		sleep(10)

		# find link with href href="#/page/search" and text 'Person Search'
		link = agent.find_element(xpath: "//a[contains(., 'Person Search')]")
		link.click
		sleep(8)

		# find input with id 'LicenseNo' and set value to license_number
		input = agent.find_element(:id, 'LicenseNo')
		input.send_keys(license_number)

		# find button with type 'submit' and click
		button = agent.find_element(:xpath, "//button[@type='submit']")
		button.click
		sleep(3)

		# find table with id DataTables_Table_2
		table = agent.find_element(:id, 'DataTables_Table_2')
		# find row with license_number
		row = table.find_element(xpath: "//tr[contains(., '#{license_number}')]")
		sleep(3)

		# find link in row with ng-click search.getAssetDetail(perDetails.LicenseNumber,perDetails.PersonId,perDetails.LicenseId)
		link = row.find_element(xpath: "//a[contains(@ng-click, 'search')]")
		link.click
		sleep(3)

		# find new page and move to the page
		agent.switch_to.window(agent.window_handles.last)
		sleep(1)

		# save_screenshot
		crawler.manage.window.resize_to(1024, 1024)
		crawler.save_screenshot(PUBLIC_PATH.join(crawler_folder, SCREENSHOT_FILENAME))

		agent.quit()
	rescue
		nil
	end

	def crawl!
		crawler.get('https://www.pals.pa.gov/')
		sleep(10)

		# find link with href href="#/page/search" and text 'Person Search'
		link = crawler.find_element(xpath: "//a[contains(., 'Person Search')]")
		link.click
		sleep(8)

		# find input with id 'LicenseNo' and set value to license_number
		input = crawler.find_element(:id, 'LicenseNo')
		input.send_keys(license_number)

		# find button with type 'submit' and click
		button = crawler.find_element(:xpath, "//button[@type='submit']")
		button.click
		sleep(3)

		# find table with id DataTables_Table_2
		table = crawler.find_element(:id, 'DataTables_Table_2')
		# find row with license_number
		row = table.find_element(xpath: "//tr[contains(., '#{license_number}')]")
		sleep(3)

		# find link in row with ng-click search.getAssetDetail(perDetails.LicenseNumber,perDetails.PersonId,perDetails.LicenseId)
		link = row.find_element(xpath: "//a[contains(@ng-click, 'search')]")
		link.click
		sleep(3)

		# find new page and move to the page
		crawler.switch_to.window(crawler.window_handles.last)
		sleep(1)

		save_screenshot

		crawler.quit()
	end
end

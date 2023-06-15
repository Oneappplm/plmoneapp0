# frozen_string_literal: true

require 'selenium-webdriver'
require 'webdrivers'

class Webscraper::OigService < ApplicationService
	attr_reader :last_name, :first_name

	def initialize(last_name = 'emmet', first_name = '')
		@last_name = last_name
		@first_name = first_name
	end

	def call

		if Rails.env.development?
			options = Selenium::WebDriver::Chrome::Options.new
		else
			Selenium::WebDriver::Chrome.path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
			options = Selenium::WebDriver::Chrome::Options.new(
					prefs: { 'profile.default_content_setting_values.notifications': 2 },
					binary: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
			)
		end

		options.add_argument('--headless')
		options.add_argument('--disable-gpu')
		options.add_argument('--no-sandbox')

		driver = Selenium::WebDriver.for :chrome, options: options
		driver.get('https://exclusions.oig.hhs.gov/default.aspx')

		driver.find_element(:id, 'ctl00_cpExclusions_txtSPLastName').send_keys(last_name)
		driver.find_element(:id, 'ctl00_cpExclusions_txtSPFirstName').send_keys(first_name)

		# click search button with id  ctl00_cpExclusions_ibSearchSP
		driver.find_element(:id, 'ctl00_cpExclusions_ibSearchSP').click
		sleep(2)

		# find table with class leie_search_results
		table = driver.find_element(:class, 'leie_search_results') rescue nil


		# if table is not present, save	screenshot and return
		if table.present?
			# find row with last name 'emmet'
			row = table.find_element(xpath: "//tr[contains(., '#{last_name.upcase}')]")
			# find link in row with text 'Verify'
			link = row.find_element(xpath: "//a[contains(., 'Verify')]")
			link.click
			sleep(2)
		end

		FileUtils.mkdir_p(Rails.root.join('public', 'webscraper', 'oig'))
		driver.manage.window.resize_to(1024, 1024)
		driver.save_screenshot(Rails.root.join('public', 'webscraper', 'oig', 'screenshot.png'))

		sleep(2)
		driver.quit()
	end
end
# frozen_string_literal: true
class Webscraper::OigService < WebscraperService
	attr_reader :last_name, :first_name

	def initialize(last_name = 'emmet', first_name = '')
		@last_name = last_name
		@first_name = first_name
	 @crawler_folder = 'oig'
	end

	def call
		crawl
	end

	def crawl!
		crawler.get('https://exclusions.oig.hhs.gov/default.aspx')

		crawler.find_element(:id, 'ctl00_cpExclusions_txtSPLastName').send_keys(last_name)
		crawler.find_element(:id, 'ctl00_cpExclusions_txtSPFirstName').send_keys(first_name)

		# click search button with id  ctl00_cpExclusions_ibSearchSP
		crawler.find_element(:id, 'ctl00_cpExclusions_ibSearchSP').click
		sleep(2)

		# find table with class leie_search_results
		table = crawler.find_element(:class, 'leie_search_results') rescue nil


		# if table is not present, save	screenshot and return
		if table.present?
			# find row with last name 'emmet'
			row = table.find_element(xpath: "//tr[contains(., '#{last_name.upcase}')]")
			# find link in row with text 'Verify'
			link = row.find_element(xpath: "//a[contains(., 'Verify')]")
			link.click
			sleep(2)
		end

		webcrawler_log = save_screenshot

		sleep(2)
		crawler.quit()
	end
end
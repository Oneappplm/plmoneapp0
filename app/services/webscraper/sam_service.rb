# frozen_string_literal: true

class Webscraper::SamService < ApplicationService
	attr_reader :last_name, :first_name

	def initialize(last_name = 'Ryals', first_name = 'Chandra')
		@last_name = last_name
		@first_name = first_name
	 @crawler_folder = 'sam'
	end

	def call
		crawl
	end

	def crawl!
		crawler.get('https://sam.gov/search/?index=ex&sort=-relevance&page=1&pageSize=25&sfm%5BsimpleSearch%5D%5BkeywordRadio%5D=ALL&sfm%5Bstatus%5D%5Bis_active%5D=true&sfm%5BclassificationWrapper%5D%5Bclassification%5D=Entity')
		sleep(5)

		# press enter on the keyboard
		crawler.action.send_keys(:enter).perform

		sleep(3)
		# find button with text Excluded Individual and click	it
		button = crawler.find_element(:xpath, "//button[contains(., 'Excluded Individual')]")
		button.click

		# find section with id usa-accordion-item-5
		section = crawler.find_element(:id, 'usa-accordion-item-5')
		# in section find input with id firstname and set value to first_name
		input = section.find_element(:id, 'firstname')
		input.send_keys(first_name)

		# in section find input with id lastname and set value to last_name
		input = section.find_element(:id, 'lastname')
		input.send_keys(last_name)

		# in section find button with class usa-button and text "Add Individual" and click it
		button = section.find_element(:xpath, "//button[contains(., 'Add Individual')]")
		button.click
		sleep(2)

	 save_screenshot
		sleep(1)

		crawler.quit()
	end
end

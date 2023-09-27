# frozen_string_literal: true

require 'nokogiri'
require	'open-uri'
require	'mechanize'

class Webscraper::StateCaliforniaService < WebscraperService
	attr_reader :license_number, :url

	def initialize(license_number)
		@license_number = license_number
		@url = 'https://search.dca.ca.gov/'
	end

	def call
		return {} unless license_number.present?

		agent = Mechanize.new{ |a|
			a.user_agent_alias = 'Mac Safari'
		}

		data = []

		page = agent.get(url)

		form = page.form_with(action: '/results')

		page = form.submit


		# # Use Nokogiri to parse the HTML
	 doc = Nokogiri::HTML(page.body)

		# Find all <article> elements
		articles = doc.css('article.post')


		# Iterate over each article
		articles.each do |article|
				# Extract the desired values
				name = article.at_css('li h3').text.strip rescue	nil
				license_number = article.at_css('li strong:contains("License Number:") + a').text.strip rescue	nil
				license_type = article.at_css('li strong:contains("License Type:")').next_sibling.text.strip rescue	nil
				license_status = article.at_css('li strong:contains("License Status:")').next_sibling.text.strip rescue	nil
				license_expiration = article.at_css('li strong:contains("Expiration Date:")').next_sibling.text.strip rescue	nil
				secondary_status = article.at_css('li strong:contains("Secondary Status:")').next_sibling.text.strip rescue	nil
				city = article.at_css('li strong:contains("City:") + span').text.strip rescue	nil
				state = article.at_css('li strong:contains("State:") + span').text.strip rescue	nil
				county = article.at_css('li strong:contains("County:")').next_sibling.text.strip rescue	nil
				zip = article.at_css('li strong:contains("Zip:")').next_sibling.text.strip rescue	nil

				# Create a hash for the current data row
				data_row = {
						name: name,
						license_number: license_number,
						license_type: license_type,
						license_status: license_status,
						license_expiration: license_expiration,
						secondary_status: secondary_status,
						city: city,
						state: state,
						county: county,
						zip: zip
				}

				# Add the data row to the array
				data << data_row
				# WebscraperCaliforniaState.find_or_create_by!(data_row)
		end

		# puts 'Done'
		data
	end
end

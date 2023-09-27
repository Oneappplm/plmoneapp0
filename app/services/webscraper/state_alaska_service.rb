# frozen_string_literal: true
require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Webscraper::StateAlaskaService < WebscraperService
	attr_reader :url, :license_number, :program, :license_type

	def initialize(license_number = '100782', program = 'Medical', license_type = nil,  url	= 'https://www.commerce.alaska.gov/cbp/main/Search/Professional')
		@url = url
		@license_number = license_number
		@program = program
		@license_type = license_type
	end

	def call
		return unless url.present?

		agent = Mechanize.new{ |a|
			a.user_agent_alias = 'Mac Safari'
		}

		# Set the request headers
		headers = {
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
			'Accept-Language' => 'en-PH,en-US;q=0.9,en;q=0.8',
			'Cache-Control' => 'max-age=0',
			'Connection' => 'keep-alive',
			'Content-Type' => 'application/x-www-form-urlencoded',
			'Cookie' => '_ga=GA1.2.609687314.1684468403; _gid=GA1.2.1491874590.1684997312; _gat_gtag_UA_73208708_1=1; TScf54ea41077=0890181cafab2800b1d634806fd51c0ea165abf5e4c1df494be846a8c2e4285efa96f2ff82f4857a2cd2edfc7aab439208c68ccade17200098ecc42803db5045b9ecf107e2daf72f8f3b5c99b19e1b42b576a568de1aedfa; TSPD_101=0890181cafab28006f9507306ee5a3016a96b460155e7c72bdf24fb62004583cbce8cf855fd00421102f52f798037dfc08ea1d2baa05180070b218bdffa42108fd3865a4da6f2348bb847a5b0d32231b; TS3c5043ea027=0890181cafab200077d834c4cf8a3afe329829f4b8f112b933db7ddc60db74b36389c281bb054058086f32a5c91130005d9919985dc85de606997663fcb9d3b586b75c1e6582ea1582cc9d803006b9406062ed628c6d35915bb560c2ead987d5',
			'Origin' => 'https://www.commerce.alaska.gov',
			'Referer' => 'https://www.commerce.alaska.gov/cbp/main/Search/Professional',
			'Sec-Fetch-Dest' => 'document',
			'Sec-Fetch-Mode' => 'navigate',
			'Sec-Fetch-Site' => 'same-origin',
			'Sec-Fetch-User' => '?1',
			'Upgrade-Insecure-Requests' => '1',
			'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
			'sec-ch-ua' => '"Google Chrome";v="113", "Chromium";v="113", "Not-A.Brand";v="24"',
			'sec-ch-ua-mobile' => '?0',
			'sec-ch-ua-platform' => '"macOS"'
		}

		# Set the request payload
		payload = {
			'LicenseNumber' => license_number,
			'CurrentOnly' => 'false',
			# 'ProgramId' => '29',
			# 'LicenseTypeId' => '218',
			'DBA' => '',
			'IsDBAStartsWithSearch' => 'False',
			'OwnerEntityName' => '',
			'IsEntityNameStartsWithSearch' => 'False',
			'City' => ''
		}

		# Make the POST request
		response = agent.post('https://www.commerce.alaska.gov/cbp/main/Search/Professional', payload, headers)

		# Parse the HTML response
		doc = Nokogiri::HTML(response.body)

		# Initialize an array to store the extracted data
		data_array = []

		# Find all rows in the table body
		rows = doc.css('table.deptGridView tbody tr')

		# Iterate over each row
		rows.each do |row|
				# Initialize a hash to store the row data
				data_hash = {}

				# Extract values from each column
				program = row.at_css('td[data-th="Program"]').text.strip
				license_number = row.at_css('td[data-th="License Number"] a').text.strip
				dba = row.at_css('td[data-th="DBA"]').text.strip
				owners = row.at_css('td[data-th="Owners"]').text.strip
				status = row.at_css('td[data-th="Status"]').text.strip
				license_expiration = row.at_css('td[data-th="License Expiration"]').text.strip

				# Add the values to the hash
				data_hash['Program'] = program
				data_hash['License Number'] = license_number
				data_hash['DBA'] = dba
				data_hash['Owners'] = owners
				data_hash['Status'] = status
				data_hash['License Expiration'] = license_expiration

				# Add the hash to the data array
				data_array << data_hash
		end

	 # Output the array of hashes
	 data_array

	end
end

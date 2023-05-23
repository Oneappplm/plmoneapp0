# frozen_string_literal: true
require 'nokogiri'
require 'open-uri'

class Webscraper::StateAlaskaService < ApplicationService
	attr_reader :url

	def initialize(url	= 'https://www.commerce.alaska.gov/cbp/main/Search/Professional')
		@url = url
	end

	def call
		return unless url.present?

		require 'mechanize'
  agent = Mechanize.new{ |a|
			a.user_agent_alias = 'Mac Safari'
		}

		data = []
		index_counter = 0

		loop do
			index_counter += 1

			url = "https://www.commerce.alaska.gov/cbp/main/Search/ProfessionalResults?CurrentOnly=False&ProgramId=0&LicenseTypeId=0&IsDBAStartsWithSearch=False&IsEntityNameStartsWithSearch=False&pageNumber=#{index_counter}"
			page = agent.get(url)

			table = page.at('.deptGridView') # Replace with the selector for the table


			table.search('tr').each do |row|
					# Create a new hash for each row
					row_data = {}

					# Process each cell in the row
					row.search('td').each_with_index do |cell, index|
							# Extract the value from the cell and store it in the hash
							# column_name = "column_#{index + 1}" # Create a column name or use your own naming convention
							column_name = case index
								when 0 then 'program'
								when 1 then 'license_number'
								when 2 then 'dba'
								when 3 then 'owners'
								when 4 then 'status'
								when 5 then 'license_expiration'
								else
								"column_#{index + 1}"
							end


							row_data[column_name] = cell.text.strip
					end

					WebscraperAlaskaState.find_or_create_by!(row_data)
			end
		rescue
			break
		end

		# Print out the data array
		# puts WebscraperAlaskaState.last
		puts 'Done'

	end

	def call_with_submit_form
		return unless url.present?

		require 'mechanize'
  agent = Mechanize.new{ |a|
			a.user_agent_alias = 'Mac Safari'
		}

		page = agent.get(url)

		form = page.form_with(action: '/cbp/main/Search/Professional') # Replace with the actual form action attribute value

		# Fill in the form fields as needed
		# form.field_with(name: 'field_name').value = 'field_value' # Replace with the name and value of the form field

		# Submit the form
		search_page = form.submit

		data = []



		# Now you can continue scraping on the resulting page
		# For example, you can extract data from a table with the class 'deptGridView'

		loop do
			table = search_page.at('.deptGridView') # Replace with the selector for the table

			table.search('tr').each do |row|
					# Create a new hash for each row
					row_data = {}

					# Process each cell in the row
					row.search('td').each_with_index do |cell, index|
							# Extract the value from the cell and store it in the hash
							# column_name = "column_#{index + 1}" # Create a column name or use your own naming convention
							column_name = case index
								when 0 then 'program'
								when 1 then 'license_number'
								when 2 then 'dba'
								when 3 then 'owners'
								when 4 then 'status'
								when 5 then 'license_expiration'
								else
								"column_#{index + 1}"
							end


							row_data[column_name] = cell.text.strip
					end

					# Store the row hash in the data array
					data << row_data
			end

			 # Find and click the "Next" link if it exists
				next_link = search_page.at('.deptButton.icoNextAfter') # Replace with the selector for the "Next" link
				break unless next_link

				# Follow the "Next" link
				# binding.break
				search_page = next_link.click
		end

		# Print the data array
		puts data

		# /cbp/main/Search/ProfessionalResults?CurrentOnly=False&ProgramId=0&LicenseTypeId=0&IsDBAStartsWithSearch=False&IsEntityNameStartsWithSearch=False

		# https://www.commerce.alaska.gov/cbp/main/Search/ProfessionalResults?CurrentOnly=False&ProgramId=0&LicenseTypeId=0&IsDBAStartsWithSearch=False&IsEntityNameStartsWithSearch=False&pageNumber=3&_=1684751277333


	end
end

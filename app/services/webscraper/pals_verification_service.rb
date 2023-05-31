# frozen_string_literal: true
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'json'

class Webscraper::PalsVerificationService < ApplicationService
	attr_reader :license_number

	def initialize(license_number	= nil)
		@license_number = license_number
	end

	def call
		return {}	if license_number.blank?
		# MD063880L
		# Bhavank V. Doshi MD


		agent = Mechanize.new{ |a|
				a.user_agent_alias = 'Mac Safari'
			}

		headers = {
			'Accept' => 'application/json, text/plain, */*',
			'Accept-Language' => 'en-PH,en-US;q=0.9,en;q=0.8',
			'Content-Type' => 'application/json;charset=UTF-8',
			'Request-Id' => '|IPueL.pdMlV',
			'Sec-Ch-Ua' => '"Google Chrome";v="113", "Chromium";v="113", "Not-A.Brand";v="24"',
			'Sec-Ch-Ua-Mobile' => '?0',
			'Sec-Ch-Ua-Platform' => '"macOS"',
			'Sec-Fetch-Dest' => 'empty',
			'Sec-Fetch-Mode' => 'cors',
			'Sec-Fetch-Site' => 'same-origin'
	}

	data = {
				OptPersonFacility: 'Person',
				LicenseNumber: license_number,
				State: '',
				Country: 'ALL',
				County: nil,
				IsFacility: 0,
				PersonId: nil,
				PageNo: 1
		}

		url = 'https://www.pals.pa.gov/api/Search/SearchForPersonOrFacilty'

		response = agent.post(url, data.to_json, headers)
		JSON.parse(response.body)
	end
end

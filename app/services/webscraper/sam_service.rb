# frozen_string_literal: true

class Webscraper::SamService < ApplicationService
	def call
		crawl
	end
end

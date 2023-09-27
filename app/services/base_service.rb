class BaseService < ApplicationService
	def process_data = {}
	def filtered_response = {}
	def check_errors = nil

	def call
		check_errors
		return self if errors?

		process_data

		send_result filtered_response
	end
end
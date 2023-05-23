class PalsVerificationsController < ApplicationController
	def index
		@pals = if params[:license_number].present?
			Webscraper::PalsVerificationService.call(params[:license_number])
		else
			Webscraper::PalsVerificationService.call
		end
	end
end
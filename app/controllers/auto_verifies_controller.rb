class AutoVerifiesController < ApplicationController
	def index
		@results = if params[:search_state].present?
			search_state	= params[:search_state].downcase
			if search_state == 'pals'
				Webscraper::PalsVerificationService.call(params[:license_number])
			elsif search_state == 'alaska'
				Webscraper::StateAlaskaService.call(params[:license_number])
			elsif search_state == 'california'
				Webscraper::StateCaliforniaService.call(params[:license_number])
			else
				[]
			end
		else
			[]
		end
	end
end
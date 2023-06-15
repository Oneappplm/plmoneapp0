class AutoVerifiesController < ApplicationController
	def index
		@results = if params[:search_state].present?
			search_state	= params[:search_state].downcase
			if search_state == 'pals' && params[:license_number].present?
				Webscraper::PalsVerificationService.call(params[:license_number])
			elsif search_state == 'alaska' && params[:license_number].present?
				Webscraper::StateAlaskaService.call(params[:license_number])
			elsif search_state == 'california' && params[:license_number].present?
				Webscraper::StateCaliforniaService.call(params[:license_number])
			elsif search_state == 'oig'
				Webscraper::OigService.call(params[:last_name], params[:first_name])
			else
				[]
			end
		else
			[]
		end
	end
end
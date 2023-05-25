class Webscrapers::AlaskaStatesController < ApplicationController
	def index
		@alaska_states = if params[:license_number].present?
			Webscraper::StateAlaskaService.call(params[:license_number], params[:program], params[:license_type])
		else
			[]
		end
	end
end
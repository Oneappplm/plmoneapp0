class Webscrapers::AlaskaStatesController < ApplicationController
	def index
		@alaska_states = if params[:search].present?
				WebscraperAlaskaState.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
			else
				WebscraperAlaskaState.paginate(per_page: 10, page: params[:page] || 1)
			end
	end

	def crawl
		Webscraper::StateAlaskaService.call

		redirect_to webscrapers_alaska_states_path, notice: 'Crawling has been successfully completed.'
	rescue
	 redirect_to webscrapers_alaska_states_path, notice: 'Crawling has been successfully completed.'
	end
end
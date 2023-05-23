class Webscrapers::CaliforniaStatesController < ApplicationController
	def index
		@california_states = if params[:search].present?
				WebscraperCaliforniaState.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
			else
				WebscraperCaliforniaState.paginate(per_page: 10, page: params[:page] || 1)
			end
	end

	def crawl
		Webscraper::StateCaliforniaService.call

		redirect_to webscrapers_california_states_path, notice: 'Crawling has been successfully completed.'
	rescue
	 redirect_to webscrapers_california_states_path, notice: 'Crawling has been successfully completed.'
	end

	def clear
		WebscraperCaliforniaState.delete_all

		redirect_to webscrapers_california_states_path, notice: 'All records has been successfully deleted.'
	end
end
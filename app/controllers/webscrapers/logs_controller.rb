class Webscrapers::LogsController < ApplicationController
	def index
		@logs = WebcrawlerLog.all
		if params[:logid].present?
			log =	WebcrawlerLog.find(params[:logid])
			pdf_path = Rails.root.join(log.filepath)
			send_file pdf_path, type: 'application/pdf', disposition: 'attachment'
		end
	end
end

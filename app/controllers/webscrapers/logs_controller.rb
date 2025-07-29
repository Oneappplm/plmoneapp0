class Webscrapers::LogsController < ApplicationController
	def index
		@logs = WebcrawlerLog.all
		if params[:logid].present?
			log =	WebcrawlerLog.find(params[:logid])
			if log.filepath&.path && File.exist?(log.filepath.path)
			  send_file log.filepath.path, type: 'application/pdf', disposition: 'attachment'
			else
			  render plain: "File not found", status: :not_found
			end
		end
	end
end

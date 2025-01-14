class Webscrapers::QualityAuditsController < ApplicationController
  def run_webcrawler
    # Extract parameters sent via AJAX
    last_name = params[:last_name] || 'emmet'   # Default to 'emmet' if not provided
    first_name = params[:first_name] || ''       # Default to empty string if not provided

    # Create the service instance and call it with parameters
    service = Webscraper::OigService.new(last_name, first_name)
    service.call
    render json: { message: 'Webcrawler completed successfully' }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end

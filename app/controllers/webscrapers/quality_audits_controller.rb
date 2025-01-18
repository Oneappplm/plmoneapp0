class Webscrapers::QualityAuditsController < ApplicationController
  def run_oig_webcrawler
    last_name = params[:last_name]
    first_name = params[:first_name]

    # Create RVA information for OIG when running webcrawler
    rva_information = RvaInformation.create(
      tab: 'OIG',
      send_request: 'SENT',
      requested_by: 'SYSTEM',
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_status: true,
      comments: 'Webcrawler',
      received_by: 'SYSTEM',
      received_date: Date.today
    )

    # Create the service instance and call it with parameters
    service = Webscraper::OigService.new(last_name, first_name)
    service.call

    # Define source file path
    source_file = Rails.root.join('public', 'webscrape', 'oig', 'screenshot.pdf')

    # Generate unique filename
    timestamp = Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    random_string = SecureRandom.hex(4)
    filename = "OIG_OIG_#{last_name.upcase}_#{first_name.upcase}_#{timestamp}_#{random_string}_M.pdf"

    # Copy the file to a temporary directory for uploading
    tmp_file_path = Rails.root.join('tmp', filename)
    FileUtils.cp(source_file, tmp_file_path)

    # Save the file in WebscraperLog using CarrierWave
    webscraper_log = WebcrawlerLog.new(
      crawler_type: 'OIG',
      status: 'completed'
    )
    webscraper_log.filepath = File.open(tmp_file_path) # Attach the file using CarrierWave
    webscraper_log.save!

    # Remove the temporary file after saving
    File.delete(tmp_file_path) if File.exist?(tmp_file_path)

    render json: { message: 'Webcrawler completed successfully', rva_information: rva_information, webscraper_log: webscraper_log }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def send_request
    last_name = params[:last_name] 
    first_name = params[:first_name]
    # Create reva informaton for send request 
    rva_information = RvaInformation.create(tab: 'OIG', send_request: 'SENT', requested_by: first_name, requested_date: Date.today, requested_method: 'Letter', required_fee_amount: 0, check_generated: false, received_by: first_name, received_status: true, comments: 'none', received_date: Date.today)
    render json: { message: 'requestsent sccessfully',  rva_information: rva_information}, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end

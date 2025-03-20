class Webscrapers::QualityAuditsController < ApplicationController
  def run_oig_webcrawler
    last_name = params[:last_name]
    first_name = params[:first_name]
    provider_personal_info = ProviderPersonalInformation.find(params[:info_id])

    # Create RVA information for OIG when running webcrawler
    rva_information = RvaInformation.create!(
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
      provider_personal_information_id: provider_personal_info.id,
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
    webscraper_log = OigWebcrawlerLog.new(
      status: 'completed',
      rva_information_id: rva_information.id
    )
    webscraper_log.filepath = File.open(tmp_file_path) # Attach the file using CarrierWave
    webscraper_log.save!

    # Remove the temporary file after saving
    File.delete(tmp_file_path) if File.exist?(tmp_file_path)
    if params[:info_id].present?
      provider_personal_info.update(verification_status: 'Processing')
    end

    render json: { message: 'Webcrawler completed successfully', rva_information: rva_information, webscraper_log: webscraper_log }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def run_registration_webcrawler
    dea_number = params[:dea_number]
    last_name = params[:last_name]
    first_name = params[:first_name]

    provider_dea = ProviderDea.find(params[:provider_dea_id])
  
    # Create RVA information for Registration when running webcrawler
    rva_information = RvaInformation.create!(
      tab: 'Registration',
      send_request: 'SENT',
      requested_by: 'SYSTEM',
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_status: true,
      comments: 'Webcrawler',
      received_by: 'SYSTEM',
      provider_dea_id: provider_dea.id,
      received_date: Date.today
    )
  
    # Create the service instance and call it with parameters
    reference_html = 'dea_template.html'
    service = Webscraper::DeaService.new(dea_number, reference_html)
    service.call
  
    # Define source file path
    source_file = Rails.root.join('public', 'screenshots', 'dea_screenshot.pdf')
  
    # Generate unique filename
    timestamp = Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    random_string = SecureRandom.hex(4)
    filename = "DEA_#{last_name.upcase}_#{first_name.upcase}_#{timestamp}_#{random_string}_M.pdf"
  
    # Copy the file to a temporary directory for uploading
    tmp_file_path = Rails.root.join('tmp', filename)
    FileUtils.cp(source_file, tmp_file_path)
  
    # Save the file in WebscraperLog using CarrierWave
    webscraper_log = DeaWebcrawlerLog.new(status: 'completed',rva_information_id: rva_information.id, filetype: 'PDF')
    webscraper_log.filepath = File.open(tmp_file_path) # Attach the file using CarrierWave
    webscraper_log.save!
  
    # Remove the temporary file after saving
    File.delete(tmp_file_path) if File.exist?(tmp_file_path)
  
    if params[:info_id].present?
      provider_personal_info.update(verification_status: 'Processing')
    end
  
    render json: { message: 'Registration Webcrawler completed successfully', rva_information: rva_information, webscraper_log: webscraper_log }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end  

  def send_oig_request
    last_name = params[:last_name] 
    first_name = params[:first_name]

    infoId = params[:personal_info_id]
    # Create reva informaton for send request 
    rva_information = RvaInformation.create!(
      tab: 'OIG', 
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today, 
      requested_method: 'Letter', 
      required_fee_amount: 0, 
      check_generated: false, 
      received_by: current_user.first_name, 
      received_status: true, 
      comments: 'none', 
      received_date: Date.today, 
      provider_personal_information_id: infoId)
    render json: { message: 'requestsent sccessfully',  rva_information: rva_information}, status: :ok
    if infoId.present?
      ProviderPersonalInformation.find(infoId).update(verification_status: 'Processing')
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def run_licensure_webcrawler
    last_name = params[:last_name]
    first_name = params[:first_name]
    license_number = params[:license_number]  # License number added
    provider_personal_info = ProviderPersonalInformation.find(params[:info_id])

    # Create RVA information for Licensure when running webcrawler
    rva_information = RvaInformation.create!(
      tab: 'Licensure',
      send_request: 'SENT',
      requested_by: 'SYSTEM',
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_status: true,
      comments: 'Webcrawler',
      received_by: 'SYSTEM',
      provider_personal_information_id: provider_personal_info.id,
      received_date: Date.today
    )

    # Create the service instance and call it with parameters
    service = Webscraper::LicensureService.new(last_name, first_name, license_number)
    service.call

    # Define source file path
    source_file = Rails.root.join('public', 'webscrape', 'licensure', 'screenshot.pdf')

    # Generate unique filename including license_number
    timestamp = Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    random_string = SecureRandom.hex(4)
    filename = "LICENSURE_#{last_name.upcase}_#{first_name.upcase}_#{license_number}_#{timestamp}_#{random_string}_M.pdf"

    # Copy the file to a temporary directory for uploading
    tmp_file_path = Rails.root.join('tmp', filename)
    FileUtils.cp(source_file, tmp_file_path)

    # Save the file in WebscraperLog using CarrierWave
    webscraper_log = LicensureWebcrawlerLog.new(
      status: 'completed',
      rva_information_id: rva_information.id
    )
    webscraper_log.filepath = File.open(tmp_file_path) # Attach the file using CarrierWave
    webscraper_log.save!

    # Remove the temporary file after saving
    File.delete(tmp_file_path) if File.exist?(tmp_file_path)
    if params[:info_id].present?
      provider_personal_info.update(verification_status: 'Processing')
    end

    render json: { message: 'Licensure webcrawler completed successfully', rva_information: rva_information, webscraper_log: webscraper_log }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def send_licensure_request
    infoId = params[:personal_info_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'Licensure',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'none',
      received_date: Date.today,
      provider_personal_information_id: infoId
    )

    render json: { message: 'licensure request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end  

  def send_employment_request
    infoId = params[:personal_info_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'Employment',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'none',
      received_date: Date.today,
      provider_personal_information_id: infoId
    )

    render json: { message: 'Employment request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end 

  def send_npdb_request
    infoId = params[:personal_info_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'NPDB',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'NPDB Webcrawler Request',
      received_date: Date.today,
      provider_personal_information_id: infoId
    )

    render json: { message: 'NPDB request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  def send_registration_request
    provider_dea_id = params[:provider_dea_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'Registration',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'none',
      received_date: Date.today,
      provider_dea_id: provider_dea_id
    )

    render json: { message: 'Registration request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end  
  
  def send_liability_request

    infoId = params[:personal_info_id]
    # Create reva informaton for send request 
    rva_information = RvaInformation.create(tab: 'Liability', send_request: 'SENT', requested_by: current_user.first_name, requested_date: Date.today, requested_method: 'Letter', required_fee_amount: 0, check_generated: false, received_by: current_user.first_name, received_status: true, comments: 'none', received_date: Date.today, provider_personal_information_id: infoId)
    render json: { message: 'requestsent sccessfully',  rva_information: rva_information}, status: :ok
      if infoId.present?
        ProviderPersonalInformation.find(infoId).update(verification_status: 'Processing')
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
  end

  def send_board_cert_request
    infoId = params[:personal_info_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'BOARDCERT',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'none',
      received_date: Date.today,
      provider_personal_information_id: infoId
    )
     
    render json: { message: 'board cert request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end  

  def send_education_request
    infoId = params[:personal_info_id]
    education_id = params[:practice_education_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'EDUCATION',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'none',
      received_date: Date.today,
      provider_personal_information_id: infoId,
      practice_information_education_id: education_id
    )
     
    render json: { message: 'EDUCATION cert request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def send_education_skip_rva
    infoId = params[:personal_information_id]
    education_id = params[:education_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'EDUCATION',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'SkipRVA',
      received_date: Date.today,
      provider_personal_information_id: infoId,
      practice_information_education_id: education_id,
      source_name: 'ADA',
      source_date: Date.today,
      status: 'completed',
      verification_status: 'Verified',
      verification_date: Date.today,
      verifier: current_user.first_name,
      verification_comments: 'SkipRVA',
      audit_status: true,
      auditor: current_user.first_name,
      audit_date: Date.today,
      audit_comments: 'SkipRVA'
    )
    PracticeInformationEducation.find(params[:education_id]).update(verification_status: 'SkipRVA')
     
    render json: { message: 'EDUCATION cert request sent successfully', rva_information: rva_information, success: true }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end  

  def send_dea_skip_rva
    infoId = params[:personal_information_id]
    provider_dea_id = params[:provider_dea_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'Registration',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'SkipRVA',
      received_date: Date.today,
      provider_personal_information_id: infoId,
      provider_dea_id: provider_dea_id,
      source_name: 'ADA',
      source_date: Date.today,
      status: 'completed',
      verification_status: 'Verified',
      verification_date: Date.today,
      verifier: current_user.first_name,
      verification_comments: 'SkipRVA',
      audit_status: true,
      auditor: current_user.first_name,
      audit_date: Date.today,
      audit_comments: 'SkipRVA'
    )
     
    render json: { message: 'dea request sent successfully', rva_information: rva_information, success: true }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def send_training_request
    infoId = params[:personal_info_id]
    # Create RVA information for NPDB request
    rva_information = RvaInformation.create(
      tab: 'Training',
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: 'none',
      received_date: Date.today,
      provider_personal_information_id: infoId
    )
     
    render json: { message: 'Training request sent successfully', rva_information: rva_information }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end

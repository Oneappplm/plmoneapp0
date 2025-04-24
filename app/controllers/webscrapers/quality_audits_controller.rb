class Webscrapers::QualityAuditsController < ApplicationController
  before_action :set_common_params, only: %i[
    send_oig_request send_licensure_request send_employment_request
    send_npdb_request send_registration_request send_liability_request
    send_board_cert_request send_education_request send_education_skip_rva send_liability_skip_rva send_training_skip_rva
    send_dea_skip_rva send_training_request send_employment_skip_rva send_npdb_skip_rva send_board_cert_skip_rva
  ]
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
    create_rva_information('OIG', 'none')
  end

  def run_licensure_webcrawler
    license_number = params[:license_number]  # License number added
    provider_licensure = ProviderLicensure.find(params[:provider_licensure_id])

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
      provider_licensure_id: provider_licensure.id,
      received_date: Date.today
    )

    # Create the service instance and call it with parameters
    service = Webscraper::LicensureService.new(license_number)
    service.call

    # Define source file path
    source_file = Rails.root.join('public', 'webscrape', 'Licensure', 'screenshot.pdf')

    # Generate unique filename including license_number
    timestamp = Time.now.strftime('%Y-%m-%dT%H-%M-%S')
    random_string = SecureRandom.hex(4)
    filename = "LICENSURE_#{license_number}_#{timestamp}_#{random_string}_M.pdf"

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
    render json: { message: 'Licensure webcrawler completed successfully', rva_information: rva_information, webscraper_log: webscraper_log }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def send_licensure_request
    licensure_id = params[:licensure_id]
    create_rva_information('Licensure', 'none', licensure_id: licensure_id)
  end

  def send_employment_request
    employment_id = params[:employment_id]
    create_rva_information('Employment', 'none', employment_id: employment_id)
  end

  def send_employment_skip_rva
    employment_id = params[:employment_id]
    create_rva_information(
      'Employment', 'SkipRVA',
      employment_id: employment_id,
      skip_rva: true
    )
    ProviderEmployment.find(employment_id).update(audit_status: 'SkipRVA')
  end

  def send_npdb_request
    create_rva_information('NPDB', 'NPDB Webcrawler Request')
  end

  def delete_npdb_request
    rvas = RvaInformation.where(tab: 'NPDB', provider_personal_information_id: params[:personal_info_id])
    if rvas.any?
      rvas.destroy_all
      render json: { success: true }
    else
      render json: { success: false, message: "Not found" }, status: :not_found
    end
  end  
  
  def send_npdb_skip_rva
    npdb_id = params[:npdb_id]
    create_rva_information(
      'NPDB', 'SkipRVA',
      npdb_id: npdb_id,
      skip_rva: true
    )
  end

  def send_registration_request
    provider_dea_id = params[:provider_dea_id]
    create_rva_information('Registration', 'none', provider_dea_id: provider_dea_id)
  end

  def send_liability_request
    liability_id = params[:liability_id]
    create_rva_information('Liability', 'none', liability_id: liability_id)
  end

  def send_liability_skip_rva
    liability_id = params[:liability_id]
    field = params[:field_to_update]
  
    create_rva_information(
      'Liability', 'SkipRVA',
      liability_id: liability_id,
      skip_rva: true
    )
  
    if %w[audit_status claims_history_audit].include?(field)
      ProviderInsuranceCoverage.find(liability_id).update(field => 'SkipRVA')
    end
  end  

  def send_board_cert_request
    board_id = params[:board_id]
    create_rva_information('BOARDCERT', 'none', board_id: board_id)
  end

  def send_board_cert_skip_rva
    board_id = params[:board_id]
    create_rva_information(
      'BOARDCERT', 'SkipRVA',
      board_id: board_id,
      skip_rva: true
    )
    ProviderSpecialty.find(board_id).update(audit_status: 'SkipRVA')
  end

  def send_education_request
    education_id = params[:practice_education_id]
    create_rva_information('EDUCATION', 'none', education_id: education_id)
  end

  def send_education_skip_rva
    education_id = params[:education_id]
    create_rva_information(
      'EDUCATION', 'SkipRVA',
      education_id: education_id,
      skip_rva: true
    )
    PracticeInformationEducation.find(education_id).update(verification_status: 'SkipRVA')
  end

  def send_dea_skip_rva
    provider_dea_id = params[:provider_dea_id]
    create_rva_information(
      'Registration', 'SkipRVA',
      provider_dea_id: provider_dea_id,
      skip_rva: true
    )
  end

  def send_training_request
    training_id = params[:training_id]
    create_rva_information('Training', 'none', training_id: training_id)
  end

  def send_training_skip_rva
    training_id = params[:training_id]
    create_rva_information(
      'Training', 'SkipRVA',
      training_id: training_id,
      skip_rva: true
    )
    ProviderEducation.find(training_id).update(audit_status: 'SkipRVA')
  end

  private

  def set_common_params
    @info_id = params[:personal_info_id] || params[:personal_information_id]
    @provider_dea_id = params[:provider_dea_id]
  end

  def create_rva_information(tab, comments, provider_dea_id: nil, education_id: nil, licensure_id: nil, employment_id: nil, liability_id: nil, board_id: nil, training_id: nil, npdb_id: nil, skip_rva: false)
    rva_params = {
      tab: tab,
      send_request: 'SENT',
      requested_by: current_user.first_name,
      requested_date: Date.today,
      requested_method: 'Letter',
      required_fee_amount: 0,
      check_generated: false,
      received_by: current_user.first_name,
      received_status: true,
      comments: comments,
      received_date: Date.today,
      provider_personal_information_id: @info_id,
      provider_dea_id: provider_dea_id,
      practice_information_education_id: education_id,
      provider_licensure_id: licensure_id,
      provider_employment_id: employment_id,
      provider_insurance_coverage_id: liability_id,
      provider_specialty_id: board_id,
      provider_education_id: training_id
    }

    if skip_rva
      rva_params.merge!(
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
    end

    rva_information = RvaInformation.create!(rva_params)
    render json: {
      message: "#{tab} request sent successfully",
      rva_information: rva_information,
      success: true
    }, status: :ok

    update_verification_status if @info_id.present?
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update_verification_status
    ProviderPersonalInformation.find(@info_id).update(verification_status: 'Processing')
  end
end

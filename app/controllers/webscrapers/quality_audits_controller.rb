class Webscrapers::QualityAuditsController < ApplicationController
  before_action :set_common_params, only: %i[
    send_oig_request send_licensure_request send_employment_request
    send_npdb_request send_registration_request send_liability_request send_certification_request
    send_board_cert_request send_education_request send_education_skip_rva send_liability_skip_rva send_training_skip_rva send_dea_skip_rva send_training_request send_employment_skip_rva send_npdb_skip_rva send_board_cert_skip_rva send_oig_skip_rva send_peer_request send_peer_skip_rva
  ]
  def run_oig_webcrawler
    last_name = params[:last_name]
    first_name = params[:first_name]
    middle_name = params[:middle_name]
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
    service = Webscraper::OigService.new(last_name, first_name, middle_name)
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
    Rails.logger.error "OIG Webcrawler failed: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def run_npdb_demo_webcrawler
    npdb = ProviderNpdb.find(params[:npdb_id])
    provider_personal_info = ProviderPersonalInformation.find(params[:info_id])

    rva_information = RvaInformation.create!(
      tab: 'NPDB',
      send_request: 'SENT',
      requested_by: 'SYSTEM',
      requested_date: Date.today,
      requested_method: 'Website',
      required_fee_amount: 0,
      check_generated: false,
      received_status: true,
      comments: 'NPDB Demo Webcrawler',
      received_by: 'SYSTEM',
      provider_personal_information_id: provider_personal_info.id,
      provider_npdb_id: npdb.id,
      received_date: Date.today
    )

    log = Webscraper::NpdbQrxsService.new(
      provider_npdb: npdb,
      provider_personal_information: provider_personal_info,
      rva_information: rva_information
    ).call

    # ✅ Use real status from service
    if log.status == "completed"
      npdb.update!(
        status: "COMPLETED(DEMO)",
        submit_date: npdb.submit_date || Date.current,
        response_date: Date.current,
        comments: "DEMO: PDF generated & uploaded."
      )
    else
      npdb.update!(
        status: "FAILED(DEMO)",
        comments: "DEMO FAILED: Check PDF/log for details"
      )
    end

    provider_personal_info.update!(verification_status: 'Processing')

    render json: {
      success: log.status == "completed",
      message: log.status == "completed" ? "NPDB completed" : "NPDB failed (see PDF)",
      rva_information_id: rva_information.id,
      webscraper_log_id: log.id,
      status: log.status,
      pdf_url: log.filepath.url
    }, status: :ok

  rescue => e
    Rails.logger.error "NPDB demo failed: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      success: false,
      error: e.message
    }, status: :unprocessable_entity
  end

  def run_registration_webcrawler
    dea_number = params[:dea_number]
    first_name = params[:first_name]
    last_name  = params[:last_name]

    provider_info = ProviderPersonalInformation.find(params[:info_id])
    provider_dea  = ProviderDea.find(params[:provider_dea_id])

    # Validate DEA #
    dea_number = dea_number.to_s.upcase.gsub(/[^A-Z0-9]/, "")

    # Accept either:
    # BN9446231      (9 chars)
    # BN9446231C     (10 chars from DEA master file)
    unless dea_number.match?(/\A[A-Z]{2}\d{7}[A-Z]?\z/)
      return render json: {
        success: false,
        message: "Invalid DEA format."
      }, status: :unprocessable_entity
    end

    master =
      DeaMasterRecord.find_by(dea_number: dea_number)

    if master.blank? && dea_number.length == 9
      master =
        DeaMasterRecord.where(
          "dea_number LIKE ?",
          "#{ActiveRecord::Base.sanitize_sql_like(dea_number)}_"
        ).first
    end

    if master.blank?
      return render json: {
        success: false,
        message: "DEA Number not found in Master Database."
      }, status: :unprocessable_entity
    end

    # Create RVA
    rva_info = RvaInformation.create!(
      tab: "Registration",
      send_request: "SENT",
      requested_by: "SYSTEM",
      requested_date: Date.today,
      requested_method: "DEA Master Lookup",
      required_fee_amount: 0,
      check_generated: false,
      received_status: true,
      received_by: "SYSTEM",
      received_date: Date.today,
      comments: "Used DEA Master Database Match",
      provider_personal_information_id: provider_info.id,
      provider_dea_id: provider_dea.id
    )

    # Correct HTML TEMPLATE PATH
    reference_html = Rails.root.join("public", "dea_template.html").to_s

    # Run the service (updates the HTML and generates PDF)
    service = Webscraper::DeaService.new(
      dea_number,
      reference_html,
      master_record: master,
      provider_dea: provider_dea,
      provider_info: provider_info
    )
    wicked_pdf_path = service.call

    unless wicked_pdf_path && File.exist?(wicked_pdf_path)
      return render json: { success: false, message: "PDF generation failed." }, status: :unprocessable_entity
    end

    provider_filename = "DEA_#{dea_number}.pdf"

    final_path = Rails.root.join("tmp", provider_filename)
    FileUtils.cp(wicked_pdf_path, final_path)

    # Log PDF
    log = DeaWebcrawlerLog.new(
      status: "completed",
      rva_information_id: rva_info.id,
      filetype: "PDF"
    )
    log.filepath = File.open(final_path)
    log.save!

    File.delete(final_path) if File.exist?(final_path)

    provider_info.update(verification_status: "Processing")

    # Load updated DEA HTML
    updated_html_path = Rails.root.join("tmp", "updated_page.html")
    updated_html = File.exist?(updated_html_path) ? File.read(updated_html_path) : ""

    render json: {
      success: true,
      message: "Webcrawler completed successfully.",
      pdf_url: log.filepath.url,
      webscraper_log: {
        id: log.id,
        filepath: { url: log.filepath.url },
        created_at: log.created_at
      },
      rva_information: rva_info,
      updated_html: updated_html
    }, status: :ok
  rescue => e
    render json: { success: false, message: e.message }, status: :unprocessable_entity
  end


  def send_oig_request
    create_rva_information('OIG', 'none')
  end

  def run_licensure_webcrawler
    license_number = params[:license_number]
    provider_licensure = ProviderLicensure.find(params[:provider_licensure_id])
    provider_personal_info = ProviderPersonalInformation.find(params[:info_id])

    ActiveRecord::Base.transaction do
      # 1️⃣ Create RvaInformation record
      rva_information = RvaInformation.create!(
        tab: 'Licensure',
        send_request: 'SENT',
        requested_by: 'SYSTEM',
        requested_date: Date.today,
        requested_method: 'Letter',
        required_fee_amount: 0,
        check_generated: false,
        received_status: true,
        received_by: 'SYSTEM',
        provider_licensure_id: provider_licensure.id,
        provider_personal_information_id: provider_personal_info.id,
        received_date: Date.today,
        comments: 'Webcrawler'
      )

      # 2️⃣ Run the scraper for the specific state
      service = Webscraper::LicensureService.new(
        license_number,
        provider_licensure.state_id
      )

      screenshot_url = service.call  # returns something like "/webscrape/Licensure/FL/florida_ME165044.png"
      source_file = Rails.root.join("public", screenshot_url[1..-1]) # remove leading "/"

      unless File.exist?(source_file)
        raise "Screenshot file not found: #{source_file}"
      end

      # 3️⃣ Copy to tmp with dynamic timestamp + random string + proper extension
      ext = File.extname(source_file)  # preserves .png or .pdf
      state_name = provider_licensure.state.name.parameterize.upcase
      random_string = SecureRandom.hex(4)
      filename = "LICENSURE_#{license_number}_#{state_name}_#{random_string}#{ext}"
      tmp_file_path = Rails.root.join('tmp', filename)
      FileUtils.cp(source_file, tmp_file_path)

      # 4️⃣ Create LicensureWebcrawlerLog with file attachment
      webscraper_log = LicensureWebcrawlerLog.new(
        status: 'completed',
        rva_information_id: rva_information.id
      )
      webscraper_log.filepath = File.open(tmp_file_path)
      webscraper_log.save!

      # 5️⃣ Clean up temp file
      File.delete(tmp_file_path) if File.exist?(tmp_file_path)

      # 6️⃣ Respond with JSON for AJAX
      render json: {
        message: 'Licensure webcrawler completed successfully',
        rva_information: rva_information,
        webscraper_log: webscraper_log
      }, status: :ok
    end

  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def send_licensure_request
    licensure_id = params[:licensure_id]
    create_rva_information('Licensure', 'none', licensure_id: licensure_id)
  end

  def send_certification_request
    certification_id = params[:certification_id]
    create_rva_information('Certification', 'none', certification_id: certification_id)
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
    rva_infos = RvaInformation.where(tab: 'NPDB', provider_personal_information_id: params[:personal_info_id])
  
    if rva_infos.any?
      rva_infos.update(restart_audit: true)
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

  def send_cds_request
    provider_cd_id = params[:provider_cd_id]
    create_rva_information('CDS', 'CDS Request',  provider_cd_id: provider_cd_id,)
  end

  def delete_cds_request
    rva_infos = RvaInformation.where(
      tab: 'CDS',
      provider_cd_id: params[:provider_cd_id]
    )

    if rva_infos.any?
      rva_infos.update_all(restart_audit: true)
      render json: { success: true }
    else
      render json: { success: false, message: "Not found" }, status: :not_found
    end
  end

  def send_cds_skip_rva
    provider_cd_id = params[:provider_cd_id]

    create_rva_information(
      'CDS',
      'SkipRVA',
      provider_cd_id: provider_cd_id,
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

  def delete_provider_specialty
    rva_infos = RvaInformation.where(provider_specialty_id: params[:board_id])

    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      ProviderSpecialty.find(params[:board_id]).update(audit_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given specialty ID' }, status: :not_found
    end
  end

  def delete_registration_request
    rva_infos = RvaInformation.where(provider_dea_id: params[:provider_dea_id])

    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given specialty ID' }, status: :not_found
    end
  end

  def delete_provider_licensure
    rva_infos = RvaInformation.where(provider_licensure_id: params[:licensure_id])

    if rva_infos.any?
      rva_infos.update(restart_audit: true, send_request: nil)
      ProviderLicensure.find(params[:licensure_id]).update(audit_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given specialty ID' }, status: :not_found
    end
  end

  def delete_oig
    rva_infos = RvaInformation.where(provider_personal_information_id: params[:provider_personal_information_id]).where(tab: 'OIG')

    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given specialty ID' }, status: :not_found
    end
  end

  def delete_employment
    rva_infos = RvaInformation.where(provider_employment: params[:employment_id])

    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      ProviderEmployment.find(params[:employment_id]).update(audit_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given specialty ID' }, status: :not_found
    end
  end
  
  def delete_education_request
    rva_infos = RvaInformation.where(practice_information_education_id: params[:education_id])
  
    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      PracticeInformationEducation.find(params[:education_id]).update(verification_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given education ID' }, status: :not_found
    end
  end

  def delete_training_request
    rva_infos = RvaInformation.where(provider_education_id: params[:training_id])
  
    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      ProviderEducation.find(params[:training_id]).update(audit_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given education ID' }, status: :not_found
    end
  end

  def delete_liability_request
    liability_id = params[:liability_id]
    section = params[:liability_section].to_s # "liability_coverage" or "professional_liability"

    # Find RVA records for this liability and section
    rva_infos =
    case section
    when "liability_coverage"
      RvaInformation.where(provider_insurance_coverage_id: liability_id, liability_coverage: true)
    when "professional_liability"
      RvaInformation.where(provider_insurance_coverage_id: liability_id, professional_liability: true)
    else
      RvaInformation.none
    end

    if rva_infos.any?
      # Only restart if audited
      rva_infos.where(audit_status: true, restart_audit: [nil, false]).update_all(restart_audit: true)
        # update provider_insurance_coverages table based on section
      insurance = ProviderInsuranceCoverage.find_by(id: liability_id)
      if insurance
        if section == "liability_coverage"
          insurance.update(audit_status: "Not Requested")
        elsif section == "professional_liability"
          insurance.update(claims_history_audit: "Not Requested")
        end
      end
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: "No RVA information found for #{section.humanize}" }, status: :not_found
    end
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

  def send_oig_skip_rva
    create_rva_information('OIG', 'SkipRVA', skip_rva: true)
  end

  def send_licensure_skip_rva
    licensure_id = params[:licensure_id]
    create_rva_information(
      'Licensure', 'SkipRVA',
      licensure_id: licensure_id,
      skip_rva: true
    )
    ProviderLicensure.find(licensure_id).update(audit_status: 'SkipRVA')
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

  def send_peer_request
    peer_id = params[:peer_id]
    create_rva_information('Peer', 'none', peer_id: peer_id)
  end

  def send_peer_skip_rva
    peer_id = params[:peer_id]
    create_rva_information(
      'Peer', 'SkipRVA',
      peer_id: peer_id,
      skip_rva: true
    )
    ProviderPersonalInformationPeerRef.find(peer_id).update(audit_status: 'SkipRVA')
  end

  def delete_peer_request
    rva_infos = RvaInformation.where(provider_personal_information_peer_ref_id: params[:peer_id])
  
    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      ProviderPersonalInformationPeerRef.find(params[:peer_id]).update(audit_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given Peer ID' }, status: :not_found
    end
  end

  def send_facility_request
    facility_id = params[:facility_id]
    create_rva_information('Facility', 'none', facility_id: facility_id)
  end

  def send_facility_skip_rva
    facility_id = params[:facility_id]
    create_rva_information(
      'Peer', 'SkipRVA',
      facility_id: facility_id,
      skip_rva: true
    )
    ProviderPersonalInformationFacility.find(facility_id).update(audit_status: 'SkipRVA')
  end

  def delete_facility_request
    rva_infos = RvaInformation.where(provider_personal_information_facility_id: params[:facility_id])
  
    if rva_infos.any?
      rva_infos.update(restart_audit: true)
      ProviderPersonalInformationFacility.find(params[:facility_id]).update(audit_status: 'Not Requested')
      render json: { message: 'All related RVA information deleted successfully' }, status: :ok
    else
      render json: { error: 'No RVA information found for the given Peer ID' }, status: :not_found
    end
  end

  private

  def set_common_params
    @info_id = params[:personal_info_id] || params[:personal_information_id] || params[:info_id]
    @provider_dea_id = params[:provider_dea_id]
  end

  def create_rva_information(tab, comments, provider_dea_id: nil, education_id: nil, licensure_id: nil, employment_id: nil, liability_id: nil, board_id: nil, training_id: nil, npdb_id: nil, certification_id: nil, peer_id: nil, facility_id: nil, provider_cd_id: nil, skip_rva: false, provider_npdb_id: nil)
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
      provider_education_id: training_id,
      certification_id: certification_id,
      provider_cd_id: provider_cd_id,
      provider_npdb_id: provider_npdb_id,
      provider_personal_information_peer_ref_id: peer_id,
      provider_personal_information_facility_id: facility_id,
      liability_coverage: params[:liability_section].eql?('liability_coverage'),
      professional_liability: params[:liability_section].eql?('professional_liability')
    }

    if skip_rva
      rva_params.merge!(
        source_name: 'ADA',
        source_date: Date.today,
        status: 'completed',
        verification_status: 'Verified',
        verification_date: Time.now.in_time_zone('Pacific Time (US & Canada)').to_date,
        verifier: current_user.first_name,
        verification_comments: 'SkipRVA',
        audit_status: true,
        auditor: current_user.first_name,
        audit_date: Date.today,
        audit_comments: 'SkipRVA',
        restart_audit: false,
      )
    end
    rva_information = RvaInformation.create!(rva_params)
    render json: {
      message: "#{tab} request sent successfully",
      rva_information: rva_information,
      success: true,
    }, status: :ok

    update_verification_status if @info_id.present?
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update_verification_status
    ProviderPersonalInformation.find(@info_id).update(verification_status: 'Processing')
  end
end

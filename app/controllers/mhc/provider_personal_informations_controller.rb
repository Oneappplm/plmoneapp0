class Mhc::ProviderPersonalInformationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update]

  before_action :set_provider_personal_information, only: [:update, :update_audit_date, :submit_application]

  def update
    @provider_personal_information.assign_attributes(provider_personal_information_params)

    page_tab = params[:page_tab].presence || 'practitioner_info'

    if @provider_personal_information.save
      redirect_to mhc_verification_platform_path(
        page_tab: page_tab,
        id: @provider_personal_information.provider_attest_id
      ), notice: 'Practice information saved successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: page_tab,
        id: @provider_personal_information.provider_attest_id
      ), alert: 'Failed to save practice information.'
    end
  end


  def update_audit_date
    provider = @provider_personal_information
    return render json: { error: "Provider not found" }, status: :unprocessable_entity unless provider

    # ✅ client wants SRFD date to appear immediately after click
    audited_time = Time.current.in_time_zone('Pacific Time (US & Canada)')

    provider.update!(
      latest_audit_completed_date: audited_time
    )

    # ✅ create queue
    queue = provider.pdf_generation_queues.create!(
      status:      "queued",
      queued_date: audited_time, # use same PST time
      message:     "Processing SRFD started"
    )

    # ✅ add Verified Profile
    queue.pdf_queue_items.create!(
      file_name: "Verified Profile",
      file_path: "verified_profile",
      status:    "queued"
    )

    # ✅ add uploaded docs
    provider.provider_personal_uploaded_docs.find_each do |doc|
      next unless doc.file_upload&.url.present?

      queue.pdf_queue_items.create!(
        file_name: File.basename(URI.parse(doc.file_upload.url).path),
        file_path: doc.file_upload.url,
        status:    "queued"
      )
    end

    # ✅ add NPI log
    if (last_log = provider.npi_webcrawler_logs.last)
      queue.pdf_queue_items.create!(
        file_name: File.basename(URI.parse(last_log.filepath.url).path),
        file_path: last_log.filepath.url,
        status:    "queued"
      )
    end

    # ✅ add DEA log
    dea_log = DeaWebcrawlerLog.joins(:rva_information)
      .where(rva_informations: { provider_personal_information_id: provider.id, tab: "Registration" })
      .order(:created_at)
      .last

    if dea_log
      queue.pdf_queue_items.create!(
        file_name: File.basename(URI.parse(dea_log.filepath.url).path),
        file_path: dea_log.filepath.url,
        status:    "queued"
      )
    end

    # ✅ start jobs
    queue.pdf_queue_items.find_each do |item|
      PdfQueueItemJob.perform_later(item.id, provider.id, current_user.id)
    end

    render json: {
      message:      "SRFD queued successfully. Queue #: #{queue.id}",
      queue_number: queue.id,
      queue_status: queue.status,
      success:      true,
      latest_date: audited_time.strftime("%m/%d/%Y") # ✅ send date back for UI
    }
  end


   def submit_application
    tracking = ProviderPersonalInformationAppTracking.find(params[:tracking_id])

    submitted_time = Time.current.in_time_zone('Pacific Time (US & Canada)')

    tracking.update!(application_submitted_date: submitted_time)
    @provider_personal_information.update!(verification_status: "processing")

    render json: {
      status: "ok",
      message: "Application submitted successfully",
      submitted_date: submitted_time.strftime("%m/%d/%Y")
    }
  end

  def verify_npi
    npi_number = params[:number]
    provider   = ProviderPersonalInformation.find_by(npi: npi_number)

    scraper = Webscraper::NpiService.new(npi_number)
    png_path = scraper.call # returns full absolute path (Pathname) or nil

    if provider.present? && png_path.present?
      # scraper already saved a WebcrawlerLog with relative path under Rails.root
      timestamp      = Time.now.strftime("%Y-%m-%dT%H-%M-%S")
      random_string  = SecureRandom.hex(4)
      filename       = "NPI_#{npi_number}_#{timestamp}_#{random_string}.png"

      # source_file is the file that scraper just wrote
      source_file = png_path

      # copy file to tmp for CarrierWave upload
      tmp_file_path = Rails.root.join("tmp", filename)
      FileUtils.cp(source_file, tmp_file_path)

      log = provider.npi_webcrawler_logs.new(
        npi_number: npi_number,
        filetype: "png",
        status: "completed"
      )
      log.filepath = File.open(tmp_file_path)
      log.save!

      File.delete(tmp_file_path) if File.exist?(tmp_file_path)

      provider.update(
        npi_verification_status: "match",
        npi_source_date: Date.today
      )

      render json: {
        status: "match",
        source_date: provider.npi_source_date,
        screenshot_url: log.filepath.url,
        file_name: File.basename(log.filepath.path)
      }, serializer: nil
    else
      render json: { status: "no_match" }
    end
  end

  private

  def set_provider_personal_information
    ppi_attest_id = params.dig(:provider_personal_information, :provider_attest_id) || params[:id]
    @provider_personal_information = ProviderPersonalInformation.find_by(provider_attest_id: ppi_attest_id)
  end


  # Strong parameters for security
  def provider_personal_information_params
    params.require(:provider_personal_information).permit(
      :id, :caqh_provider_id, :provider_attest_id, :caqh_provider_attest_id, :last_name, :first_name,
      :middle_name, :suffix, :primary_practice_state, :other_name_flag, :birth_date, :us_eligible_flag, :signature_date,
      :ssn, :nid, :practitioner_type, :dea_flag, :cds_flag, :upin, :upin_flag, :npi_flag, :npi, :medicare_provider_flag,
      :medicaid_provider_flag, :other_graduate_education_flag, :fellowship_training_flag, :teaching_appointment_flag,
      :secondary_specialty_flag, :other_specialty_flag, :hospital_privilege_flag, :hospital_admitting_arrangements,
      :work_history_gap_flag, :active_military_flag, :citizenship_status, :visa_number, :federal_employee_id,
      :no_malpractice_claims_flag, :application_type, :ecfmg_flag, :ecfmg_number, :ecfmg_issue_date,
      :hospital_based_flag, :email_address, :visa_type, :visa_status, :birth_city, :birth_state,
      :tax_id, :spouse_last_name, :spouse_first_name, :other_correspondence_address,
      :emergency_contact_last_name, :emergency_contact_first_name, :emergency_contact_middle_name,
      :emergency_contact_phone, :pager_beeper_number, :answering_service_phone_number, :cell_phone_number,
      :pager_beeper_digital_flag, :visa_expiration_date, :ethnicity_description, :visa_issue_date,
      :ecfmg_expiration_date, :show_on_tickler, :work_permit_status, :spouse_middle_name,
      :state_residence_date, :citizenship_country_country_name, :marital_status_marital_status_description,
      :gender_gender_description, :birth_country_country_name, :correspondence_address_type_correspondence_address_type_descrip,
      :provider_type_provider_type_abbreviation, :graduate_type_graduate_type_description,
      :nid_country_country_name, :attest_date, :plan_provider_id, :last_recredential_date, :next_recredential_date,
      :npi_verification_status, :npi_source_date,
      :specialty_name_1, :specialty_name_2, :specialty_name_3, :specialty_name_4, :specialty_name_5,

      provider_attest_attributes: [
        :id,
        provider_other_names_attributes: [
          :id,
          :_destroy,
          :first_name,
          :middle_name,
          :last_name,
          :suffix,
          :start_date,
          :end_date,
          :other_name_explanation
        ]
      ],
      provider_personal_information_credentialing_contact_attributes: [:id, :contact_method,
      :firstname, :middlename, :lastname, :title, :address, :suffix, :phone_number, :fax, :email, :suite, :address2,
      :city, :county, :state, :zip, :country],
      provider_personal_information_confidential_contact_attributes: [:id, :contact_method,
      :firstname, :middlename, :lastname, :title, :address, :suffix, :phone_number, :fax, :email, :suite, :address2,
      :city, :county, :state, :zip, :country],
      provider_other_names_attributes: [
        :id,
        :first_name,
        :middle_name,
        :last_name,
        :suffix,
        :start_date,
        :end_date,
        :other_name_explanation,
        :_destroy
      ])
  end
end

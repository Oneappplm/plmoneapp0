class Mhc::VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]

  def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    @client_organizations = ClientOrganization.all
  end

  def show
    if params[:page_tab]
      get_data

      render params[:page_tab]
    else
      if @provider_personal_information.present?
        @rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'OIG').where.not(source_date: nil).where.not(audit_status: false)
        @dea_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'Registration').where.not(source_date: nil).where.not(audit_status: false)
        @liability_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'Liability').where.not(source_date: nil).where.not(audit_status: false)
        @board_cert_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'BOARDCERT').where.not(source_date: nil).where.not(audit_status: false)
        @licensure_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'Licensure').where.not(source_date: nil).where.not(audit_status: false)
        @certification_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'Certification').where.not(source_date: nil).where.not(audit_status: false)
        @employment_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'employment_record').where.not(source_date: nil).where.not(audit_status: false)
        @npdb_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'NPDB').where.not(source_date: nil).where.not(audit_status: false)
        @education_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'EDUCATION').where.not(source_date: nil).where.not(audit_status: false)
        @training_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'Training').where.not(source_date: nil).where.not(audit_status: false)
        @employment_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'Employment').where.not(source_date: nil).where.not(audit_status: false)
      end
      render 'overview'
    end
  end

  def send_contact
    contact_form = ContactForm.new(
      email: params[:to],
      subject: params[:subject],
      message: params[:message],
      attachments: params[:attachments]
    )
    contact_form.deliver
  end

  def generate_report
    provider_attest_id = params[:provider_attest_id]

    # Get date range from the params using the date_range method
    start_date, end_date = params[:date_range].split(" - ").map(&:to_date)

    # Find provider personal information with the matching provider_attest_id and within the date range
    @provider_personal_informations = ProviderPersonalInformation.where(provider_attest_id: provider_attest_id).where(created_at: start_date.beginning_of_day..end_date.end_of_day)

    # Generate CSV content
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Practitioner Name", "Ready for download", "In Process", "Submitted", "Incomplete Application", "Application Not Received", "Status"]

      @provider_personal_informations.each do |provider|
        csv << [
          "#{provider.fullname}, #{provider.provider_type_provider_type_abbreviation}",
          '', # Placeholder for "Ready for download"
          '', # Placeholder for "In Process"
          '', # Placeholder for "Submitted"
          '', # Placeholder for "Incomplete Application"
          '', # Placeholder for "Application Not Received"
          ''  # Placeholder for "Status"
        ]
      end
    end
      # Define the file name dynamically based on date or other logic
      file_name = "provider_report_#{Date.today}.csv"
      file_path = Rails.root.join('public', 'csv_reports', file_name)
      File.write(file_path, csv_data)

      # Log the download to the DownloadHistory table
      DownloadHistory.create(
        file_name: file_name,           # Dynamically use the actual file name
        downloaded_at: Time.now,
        user_id: current_user.id        # If user authentication is present
      )

    # Send CSV data as a downloadable file
   respond_to do |format|
      format.csv { send_data csv_data, filename: "provider_report_#{Date.today}.csv" }
    end
  end

  def download_existing_file
    file_name = params[:file_name]
    file_path = Rails.root.join('public', 'csv_reports', file_name)
    
    if File.exist?(file_path)
      send_file file_path, type: 'text/csv', disposition: 'attachment', filename: file_name
    else
      flash[:alert] = "File not found."
      redirect_to history_mhc_client_portal_index_path # Replace with actual history page path
    end
  end

  def generate_rva_information
    @rva_information = RvaInformation.find(params[:id])
    if params[:section] == "verification"
      @rva_information.verification_status = 'Verified'
      @rva_information.verification_date = Date.today
      @rva_information.verifier = current_user.first_name
      params[:rva_information][:verification_comments] = 'None'
      @rva_information.other_details = 'None'
      @rva_information.adverse_action_comments = 'None'
      @rva_information.adverse_action_status = 'close'
    end
    if params[:section] == 'audit'
      params[:rva_information][:auditor]  = current_user.first_name
      params[:rva_information][:audit_date] = Date.today
      params[:rva_information][:audit_comments] = 'None'
      if params[:practice_info_education_id].present?
        PracticeInformationEducation.find(params[:practice_info_education_id]).update(verification_status: 'Quality Audited')
      end
      if params[:practice_employment_id].present?
        ProviderEmployment.find(params[:practice_employment_id]).update(audit_status: 'Quality Audited')
      end
      if params[:practice_education_id].present?
        ProviderEducation.find(params[:practice_education_id]).update(audit_status: 'Quality Audited')
      end  
      if params[:certification_id].present?
        Certification.find(params[:certification_id]).update(audit_status: 'Quality Audited')
      end
      if params[:practice_licensure_id].present?
        ProviderLicensure.find(params[:practice_licensure_id]).update(audit_status: 'Quality Audited')
      end  
      if params[:practice_board_id].present?
        ProviderSpecialty.find(params[:practice_board_id]).update(audit_status: 'Quality Audited')
      end 
      if params[:practice_liability_id].present?
        ProviderInsuranceCoverage.find(params[:practice_liability_id]).update(audit_status: 'Quality Audited')
      end 
      if params[:practice_claim_history_id].present?
        ProviderInsuranceCoverage.find(params[:practice_claim_history_id]).update(claims_history_audit: 'Quality Audited')
      end 
    end
    if params[:personal_info_id].present?
      ProviderPersonalInformation.find(params[:personal_info_id]).update(verification_status: 'completed')
    end
    if @rva_information.update(rva_information_params)
      render json: { message: 'Verification completed successfully', rva_information: @rva_information}, status: :ok
    else
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
  
  def profile_page
    @provider_personal_information = ProviderPersonalInformation.find(params[:provider_personal_info])
    unless @provider_personal_information
      flash[:error] = "Provider personal information not found."
      redirect_to mhc_verification_platform_index_path and return
    end
    @provider_oig_tab_details = @provider_personal_information.rva_informations.where(tab: 'OIG').where(status: 'completed').where.not(source_date: nil)
    @provider_npdb_tab_details = @provider_personal_information.rva_informations.where(tab: 'NPDB')
    @queues = PdfGenerationQueue.all.order(created_at: :desc)
    @psv_pdfs = SavedProfile.joins(:pdf_generation_queue)
                       .where(pdf_generation_queues: { deleted: true, provider_personal_information_id: @provider_personal_information.id })

  end
  
  protected
  
  def set_provider_personal_informations
    @provider_personal_information = ProviderPersonalInformation.find_by(provider_attest_id: params[:id])
  end

  def get_data

    if params[:page_tab] == 'practitioner_info'
      @provider_personal_information_credentialing_contact = @provider_personal_information.provider_personal_information_credentialing_contact
      @provider_personal_information_credentialing_contact ||= @provider_personal_information.build_provider_personal_information_credentialing_contact.save

      @provider_personal_information_confidential_contact = @provider_personal_information.provider_personal_information_confidential_contact
      @provider_personal_information_confidential_contact ||= @provider_personal_information.build_provider_personal_information_confidential_contact.save
    end

    if params[:page_tab] == 'education_record'
      @provider_personal_information_comment = ProviderPersonalInformationComment.new
      @provider_personal_information_comments = ProviderPersonalInformationComment.all
      @q = School.ransack(params[:q])
      @practice_information_education = PracticeInformationEducation.find_or_initialize_by(id: params[:practice_information_education_id], provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id)
      @rva_information = RvaInformation.new
      @last_rva_information = @practice_information_education.rva_informations.last
      @education_rva_information_completed = @practice_information_education.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end

    if params[:page_tab] == 'board_cert'
      @provider_specialties = ProviderSpecialty.where(provider_attest_id: @provider_personal_information.provider_attest_id)
      @q = @provider_personal_information.provider_attest.provider_specialties.ransack(params[:q]&.except(:page_tab))
      @provider_specialties = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'board_cert_info'
      @provider_specialty = ProviderSpecialty.find_or_initialize_by(id: params[:provider_specialty_id], provider_attest_id: @provider_personal_information.provider_attest_id)
      if @provider_specialty.persisted?
        @provider_personal_information_comment = ProviderPersonalInformationComment.new
        @provider_personal_information_comments = ProviderPersonalInformationComment.all
      end
      @rva_information = RvaInformation.new
      @last_rva_information = @provider_specialty.rva_informations.last
      @board_cert_rva_information_completed = @provider_specialty.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end

    # Common logic for handling nested associations
    # Common logic for handling nested associations
    def build_associations(practice_information)
      [
        :allied_health_practitioners,
        :personally_employed_practitioners,
        :licensed_members,
        :staff_spoken_foreign_languages,
        :provider_anesthesia_administrations,
        :covering_practitioners
      ].each do |association|
        practice_information.send(association).build if practice_information.send(association).empty?
      end
    end

    if params[:page_tab] == 'practice_info'
      @q = PracticeInformation.ransack(params[:q])
      @practice_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
      @url = mhc_practice_informations_path
    end

    if ['add_practice_info', 'edit_practice_info', 'practice_info_record'].include?(params[:page_tab])
      # Determine if it's a new or existing practice information
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @practice_information = if params[:page_tab] == 'add_practice_info'
                                PracticeInformation.new(
                                  provider_attest_id: @provider_personal_information.provider_attest_id,
                                  caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id
                                )
                              else
                                PracticeInformation.find_or_initialize_by(
                                  id: params[:practice_information_id],
                                  provider_attest_id: @provider_personal_information.provider_attest_id,
                                  caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id
                                )
                              end

      # Build associations if necessary
      build_associations(@practice_information)

      # Set @url based on specific tab
      case params[:page_tab]
      when 'add_practice_info'
        @url = mhc_practice_informations_path  # Assign URL for adding new practice info
      when 'edit_practice_info'
        @url = mhc_practice_information_path(@practice_information)  # Edit path for existing practice info
      when 'practice_info_record'
        @url = mhc_practice_information_path(@practice_information)
      end
    end

    if params[:page_tab] == 'education'
      @q = @provider_personal_information.provider_attest.practice_information_educations.ransack(params[:q]&.except(:page_tab))
      @practice_information_educations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'certifications'
      @certifications = Certification.all
      @q = @provider_personal_information.provider_attest.certifications.ransack(params[:q]&.except(:page_tab))
      @certifications = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end  
     
    if params[:page_tab] == 'add_new_certification'
      @certification = Certification.new(
        provider_attest_id: @provider_personal_information&.provider_attest_id,
        caqh_provider_attest_id: @provider_personal_information&.caqh_provider_attest_id
      )
      @url = mhc_certifications_path(provider_attest_id: @provider_personal_information&.provider_attest_id)
    end 

    if params[:page_tab] == 'certification_info' && params[:certification_id].present?
      @certification = Certification.find_by(id: params[:certification_id])
      @url = mhc_certification_path(@certification) 
      @rva_information = RvaInformation.new
      @last_rva_information = @certification.rva_informations.last
      @certification_rva_information_completed = @certification.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end       

    if params[:page_tab] == 'training'
      @q = @provider_personal_information.provider_attest.provider_educations.ransack(params[:q]&.except(:page_tab))
      @provider_educations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'training_record'
      @q = School.ransack(params[:q])
      @provider_education = ProviderEducation.find_or_initialize_by(id: params[:provider_education_id], provider_attest_id: @provider_personal_information.provider_attest_id)
      if @provider_education.persisted?
        @provider_personal_information_comment = ProviderPersonalInformationComment.new
        @provider_personal_information_comments = ProviderPersonalInformationComment.all
      end
      @rva_information = RvaInformation.new
      @last_rva_information = @provider_education.rva_informations.last
      @training_rva_information_completed = @provider_education.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end

    if params[:page_tab] == 'sam'
      @provider_personal_information_sam_records = @provider_personal_information.provider_personal_information_sam_records
    end

    if params[:page_tab] == 'sam_record'
      @provider_personal_information_sam_record = ProviderPersonalInformationSamRecord.find(params[:provider_personal_information_sam_record_id])
    end

    if params[:page_tab] == 'add_new_sam'
      @provider_personal_information_sam_record = ProviderPersonalInformationSamRecord.new(provider_personal_information_id:  @provider_personal_information.id)
    end

    if params[:page_tab] == 'oig'
      @rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'OIG').where.not(source_date: nil).where.not(audit_status: false)
      @provider_personal_information_reinstatements = ProviderPersonalInformationReinstatement.where(provider_personal_information_id:  @provider_personal_information.id)
      @provider_personal_information_comment = ProviderPersonalInformationComment.new
      @provider_personal_information_comments = ProviderPersonalInformationComment.all
      @rva_information = RvaInformation.new
      @oig_webcrawler_logs = OigWebcrawlerLog.order(updated_at: :desc)
      @last_rva_information = @provider_personal_information.rva_informations.where(tab: 'OIG').last
    end

    if params[:page_tab] == 'add_oig_info'
      @provider_personal_information_reinstatement = ProviderPersonalInformationReinstatement.new(provider_personal_information_id:  @provider_personal_information.id)
    end

    if params[:page_tab] == 'show_sam_record'
      @provider_personal_information_sam_rva_record = ProviderPersonalInformationSamRvaRecord.find_or_initialize_by(id: params[:provider_personal_information_sam_rva_record_id], provider_personal_information_sam_record_id: params[:provider_personal_information_sam_record_id])
    end

    if params[:page_tab] == 'registration'
      @provider_personal_information = ProviderPersonalInformation.find_by(id: params[:provider_personal_information_id] || params[:id])
      @provider_deas = @provider_personal_information&.provider_deas.order(:id)
      @provider_cd = ProviderCd.new(caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id)
      @states = State.all
      @provider_cds = @provider_personal_information.provider_cds.order(:id)
      @new_provider_cd = ProviderCd.new(caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id, provider_attest_id: @provider_personal_information.provider_attest_id) 
      @provider_medicares = @provider_personal_information.provider_medicares.order(:id)
      @provider_medicare = ProviderMedicare.all 
      @new_provider_medicare = ProviderMedicare.new(provider_attest_id: @provider_personal_information.provider_attest_id)
      @provider_medicaids = @provider_personal_information.provider_medicaids.order(:id)
      @new_provider_medicaid = ProviderMedicaid.new(
        provider_attest_id: @provider_personal_information.provider_attest_id
      )
      @provider_militaries = @provider_personal_information.provider_militaries.order(:id)
      @new_provider_military = ProviderMilitary.new(
        provider_attest_id: @provider_personal_information.provider_attest_id
      )
      @rva_information = RvaInformation.new
    end

    if params[:page_tab] == 'billing_info'
      @billing_companies = BillingCompany.all
    end 

    if params[:page_tab] == 'show_billing_info'
      @billing_company = BillingCompany.find_by(id: params[:id])
      
      if @billing_company.nil?
        redirect_to mhc_verification_platform_path(page_tab: 'billing_info'),
                    alert: 'Billing company not found.'
      end
    end

    if params[:page_tab] == 'liability'
      @q = ProviderInsuranceCoverage.ransack(params[:q])
      @provider_insurance_coverages = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
      @states = State.all
      @limit = 10 # Set limit
      @total_pages = (@provider_insurance_coverages_count.to_f / @limit.to_f).ceil
    end

    if params[:page_tab] == 'add_new_liability'
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      if params[:coverage_id].present?
        @provider_insurance_coverage = ProviderInsuranceCoverage.find(params[:coverage_id])
      else
        @provider_insurance_coverage = ProviderInsuranceCoverage.new(provider_attest_id: @provider_attest_id)
      end
    end

    if params[:page_tab] == 'liability_info'
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @provider_insurance_coverages = ProviderInsuranceCoverage.find(params[:coverage_id])
      @rva_information = RvaInformation.new
      @last_rva_information = @provider_insurance_coverages&.rva_informations&.last
      @liability_rva_information_completed = @provider_insurance_coverages&.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end

    if params[:page_tab] == 'npdb'
      @provider_personal_information_reinstatements = ProviderPersonalInformationReinstatement.where(provider_personal_information_id: @provider_personal_information.id)
      @provider_personal_information_comment = ProviderPersonalInformationComment.new
      @provider_personal_information_comments = ProviderPersonalInformationComment.all
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @provider_npdb = ProviderNpdb.find_or_initialize_by(
        provider_attest_id: @provider_attest_id,
        caqh_provider_attest_id: @provider_personal_information&.caqh_provider_attest_id
      )
      @rva_information = RvaInformation.new
      @last_rva_information = @provider_personal_information.rva_informations.where(tab: 'NPDB').last
      @npdb_rva_information_completed = @provider_personal_information.rva_informations.where(tab: 'NPDB').where.not(source_date: nil).where.not(audit_status: false)
    end

    if params[:page_tab] == 'app_tracking'
      @provider_personal_information_app_trackings = ProviderPersonalInformationAppTracking.where(provider_personal_information_id: @provider_personal_information.id).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'app_tracking_record'
      @provider_personal_information_app_tracking = ProviderPersonalInformationAppTracking.where(id: params[:provider_personal_information_app_tracking_id]).first_or_initialize(provider_personal_information_id: @provider_personal_information.id)
      @provider_information_names = ProviderPersonalInformation.select(:id, "CONCAT(last_name,', ',first_name, ' ', middle_name) as name").all.collect { |provider_personal_information| [provider_personal_information.name, provider_personal_information.id]}
      @selected_issues = @provider_personal_information_app_tracking.master_issues
      @selected_reviews = @provider_personal_information_app_tracking.master_reviews
    end

    if params[:page_tab] == 'add_new_employment'
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
    
      if params[:employment_id].present?
        @provider_employment = ProviderEmployment.find(params[:employment_id])
      else
        @provider_employment = ProviderEmployment.new(provider_attest_id: @provider_attest_id)
      end
    end
    
    if params[:page_tab] == 'employment'
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @provider_employments = ProviderEmployment.all
      @q = @provider_personal_information.provider_attest.provider_employments.ransack(params[:q]&.except(:page_tab))
      @provider_employments = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end
    
    if params[:page_tab] == 'employment_record' 
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      if params[:employment_id].present?
        @provider_employment = ProviderEmployment.find(params[:employment_id])
      else
        @provider_employment = ProviderEmployment.new
      end
      @rva_information = RvaInformation.new
      @last_rva_information = @provider_employment.rva_informations.last
      @employment_rva_information_completed = @provider_employment.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end

    # code for licensure tab
    if %w[edit_licensure license_record].include?(params[:page_tab])
      @provider_licensure = ProviderLicensure.find(params[:licensure_id])
      @rva_information = RvaInformation.new
      @last_rva_information = @provider_licensure.rva_informations.last
      @licensure_rva_information_completed = @provider_licensure.rva_informations.where.not(source_date: nil).where.not(audit_status: false)
    end
    
    case params[:page_tab]
    when "licensure"
      @q = ProviderLicensure.ransack(params[:q])
      @provider_licensures = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
      @limit = 10
      @total_pages = (@provider_insurance_coverages_count.to_f / @limit.to_f).ceil

    when "add_new_licensure"
      if @provider_personal_information
        @provider_attest_id = @provider_personal_information.provider_attest_id
        caqh_provider_attest_id = @provider_personal_information.caqh_provider_attest_id
      end

      @provider_licensure = ProviderLicensure.new(
        provider_attest_id: @provider_attest_id,
        caqh_provider_attest_id: caqh_provider_attest_id
      )
      @provider_licensure.provider_supervisings.build if @provider_licensure.provider_supervisings.empty?
      @url = mhc_provider_licensures_path

    when "edit_licensure"
      @url = mhc_provider_licensure_path

    when "license_record"
      # @provider_licensure is already set above
    end
  end

  def redirect_to_auto_verify
    if current_setting.dcs?
      redirect_to auto_verifies_path and return
    end
  end

  def rva_information_params
    params.require(:rva_information).permit(
      :send_request,
      :requested_by,
      :requested_date,
      :method_radio,
      :required_fee_amount,
      :check_payable_to,
      :include_delineation,
      :check_generated,
      :requested_method,
      :received_status,
      :comments,
      :source_name,
      :source_date,
      :status,
      :adverse_action,
      :other_details,
      :adverse_action_comments,
      :adverse_action_status,
      :verification_status,
      :in_good_standing,
      :error_type,
      :error_comments,
      :correct_info_selected,
      :correct_info_text,
      :verification_date,
      :verifier,
      :verification_comments,
      :audit_reason,
      :audit_reason_comments,
      :audit_status,
      :audit_date,
      :auditor,
      :audit_comments
    )
  end

end

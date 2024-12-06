class Mhc::VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]

  def index
    @q = ProviderPersonalInformation.ransack(params[:q])
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
  end

  def show
    if params[:page_tab]
      get_data

      render params[:page_tab]
    else
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

    # Send CSV data as a downloadable file
   respond_to do |format|
      format.csv { send_data csv_data, filename: "provider_report_#{Date.today}.csv" }
    end
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

    if params[:page_tab] == 'add_practice_info'
      @practice_information = PracticeInformation.new(provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id )
    end

    if params[:page_tab] == 'education_record'
      @q = School.ransack(params[:q])
      @practice_information_education = PracticeInformationEducation.find_or_initialize_by(id: params[:practice_information_education_id], provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id)
    end

    if params[:page_tab] == 'add_new_board_cert'
      @provider_specialty = ProviderSpecialty.new
    end

    if params[:page_tab] == 'board_cert'
      @provider_specialty = ProviderSpecialty.all
    end

    if params[:page_tab] == 'board_cert_info'
      # Check if provider_specialty_id is provided in the URL
      if params[:provider_specialty_id].present?
        # Fetch the specific ProviderSpecialty record
        @provider_specialty = ProviderSpecialty.find_by(id: params[:provider_specialty_id])

        unless @provider_specialty
          flash[:alert] = 'Specialty not found for the given ID.'
          redirect_to root_path and return
        end
      elsif params[:provider_attest_id].present?
        # Fallback to fetching all specialties for a provider_attest_id
        @provider_specialties = ProviderSpecialty.where(provider_attest_id: params[:provider_attest_id])

        if @provider_specialties.empty?
          flash[:alert] = 'No specialties found for the selected provider.'
        end
      else
        flash[:alert] = 'Invalid request parameters.'
        redirect_to root_path and return
      end
    end

    if params[:page_tab] == 'practice_info'
      @practice_informations = @provider_personal_information.provider_attest.practice_informations.paginate(per_page: 10, page: params[:page])
    end

    if params[:page_tab] == 'practice_info_record'
      @practice_information = @provider_personal_information.provider_attest.practice_informations.where(id: params[:practice_information_id]).last
    end

    if params[:page_tab] == 'education'
      @q = @provider_personal_information.provider_attest.practice_information_educations.ransack(params[:q]&.except(:page_tab))
      @practice_information_educations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'training'
      @q = @provider_personal_information.provider_attest.provider_educations.ransack(params[:q]&.except(:page_tab))
      @provider_educations = @q.result(distinct: true).paginate(per_page: 10, page: params[:page] || 1)
    end

    if params[:page_tab] == 'training_record'
      @q = School.ransack(params[:q])
      @provider_education = ProviderEducation.find_or_initialize_by(id: params[:provider_education_id], provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id)
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
      @provider_personal_information_reinstatements = ProviderPersonalInformationReinstatement.where(provider_personal_information_id:  @provider_personal_information.id)
    end

    if params[:page_tab] == 'add_oig_info'
      @provider_personal_information_reinstatement = ProviderPersonalInformationReinstatement.new(provider_personal_information_id:  @provider_personal_information.id)
    end

    if params[:page_tab] == 'show_sam_record'
      @provider_personal_information_sam_rva_record = ProviderPersonalInformationSamRvaRecord.find_or_initialize_by(id: params[:provider_personal_information_sam_rva_record_id], provider_personal_information_sam_record_id: params[:provider_personal_information_sam_record_id])
    end

    if params[:page_tab] == 'registration'
      @provider_deas = @provider_personal_information.provider_deas.order(:id)
      @states = State.all
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
    end

    if params[:page_tab] == 'npdb'
      @provider_npdb_comments = ProviderNpdbComment.all
      @provider_attest_id = @provider_personal_information.provider_attest_id if @provider_personal_information
      @provider_npdb = ProviderNpdb.new(
        provider_attest_id: @provider_attest_id,
        caqh_provider_attest_id: @provider_personal_information&.caqh_provider_attest_id
      )
    end

     if params[:page_tab] == 'npdb_record'
      @provider_npdb = ProviderNpdb.find_or_initialize_by(
        id: params[:provider_npdb_id],
        provider_attest_id: @provider_personal_information.provider_attest_id,
        caqh_provider_attest_id: @provider_personal_information&.caqh_provider_attest_id)
    end
  end

  def redirect_to_auto_verify
    if current_setting.dcs?
      redirect_to auto_verifies_path and return
    end
  end
end

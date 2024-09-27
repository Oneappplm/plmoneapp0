class Mhc::VerificationPlatformController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]

  def index
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end

  def show
    if params[:page_tab]
      get_data

      render params[:page_tab]
    else
      render 'overview'
    end
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
    if params[:page_tab] == 'add_practice_info'
      @practice_information = PracticeInformation.new(provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id )
    end

    if params[:page_tab] == 'add_education_info'
      @provider_education = ProviderEducation.new(provider_attest_id: @provider_personal_information.provider_attest_id, caqh_provider_attest_id: @provider_personal_information.caqh_provider_attest_id )
    end

    if params[:page_tab] == 'practice_info'
      @practice_informations = @provider_personal_information.provider_attest.practice_informations.paginate(per_page: 10, page: params[:page])
    end

    if params[:page_tab] == 'education'
      @provider_educations = @provider_personal_information.provider_attest.provider_educations.paginate(per_page: 10, page: params[:page])
    end
  end

  def redirect_to_auto_verify
    if current_setting.dcs?
      redirect_to auto_verifies_path and return
    end
  end
end

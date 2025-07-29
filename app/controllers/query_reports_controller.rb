class QueryReportsController < ApplicationController

  def index
    if params[:page].present?
      render params[:page]
    end
  end

  def staff_directory
  end

  def provider_directory
  end

  def privilege_reporting_tool
  end

  def meeting_report_by_practitioner
  end

  def cme_practitioner_profile
    @provider_personal_informations = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
  end

  def customer_reporting_service
  end

  def cme_practitioner_report
    provider_attest_id = params[:provider_attest_id]
    
    # Get date range from the params using the date_range method
    start_date, end_date = params[:date_range].split(" - ").map(&:to_date)

    # Find provider personal information with the matching provider_attest_id and within the date range
    @provider_personal_informations = ProviderPersonalInformation.where(provider_attest_id: provider_attest_id).where(created_at: start_date.beginning_of_day..end_date.end_of_day)

    # Generate CSV content
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Practitioner Name", "Select Practitioner to print"]
      
      @provider_personal_informations.each do |provider|
        csv << [
          "#{provider.id}",
          "#{provider.fullname}, #{provider.provider_type_provider_type_abbreviation}",
          ''
        ]
      end
    end

    # Send CSV data as a downloadable file
   respond_to do |format|
      format.csv { send_data csv_data, filename: "cme_practitioner_report_#{Date.today}.csv" }
    end
  end
end


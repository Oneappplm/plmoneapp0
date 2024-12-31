class Mhc::ClientPortalController < ApplicationController
  before_action :set_provider_personal_informations, only: [:show, :edit, :update]
  before_action :redirect_to_auto_verify, only: [:index]
  before_action :get_provider_types, only: [:index]
  before_action :get_states, only: [:index]
  require 'csv'

  def index
    @q = ProviderPersonalInformation.ransack(params[:q]&.except(:advanced_search))
    @provider_personal_informations = @q.result(distinct: true).paginate(per_page: 100, page: params[:page] || 1)
    @provider_personal_informations = @provider_personal_informations.order(first_name: params[:sort] == 'desc' ? :desc : :asc) if params[:sort].present?
  end

  def upload_csv
    @csv_data = session[:csv_data] || []
  end

  def process_csv
    if params[:file].present?
      file = params[:file]
      
      # Process CSV file
      csv_data = []
      CSV.foreach(file.path, headers: true).with_index do |row, index|
        break if index >= 200  # Limit to 200 rows
        csv_data << row.to_h    # Convert row to hash
      end

      # Store the CSV data in session for display
      session[:csv_data] = csv_data

      flash[:notice] = "File processed successfully"
      redirect_to upload_csv_mhc_client_portal_index_path
    else
      flash[:alert] = "Please upload a valid CSV file"
      render :upload_csv
    end
  end

  def clear_csv
    session.delete(:csv_data)
    flash[:notice] = "CSV data cleared successfully"
    redirect_to upload_csv_mhc_client_portal_index_path
  end

 def download_csv
  csv_data = session[:csv_data]

  if csv_data.present?
    # Generate the CSV file
    csv_content = CSV.generate(headers: true) do |csv|
      csv << csv_data.first.keys  # Add headers
      csv_data.each do |row|
        csv << row.values         # Add row values
      end
    end

    # Send CSV as file to the user
    send_data csv_content, filename: "uploaded_data.csv", type: "text/csv"
  else
    flash[:alert] = "No CSV data to download"
    redirect_to upload_csv_mhc_client_portal_index_path
  end
end

  def show
    if params[:page_tab]
      render params[:page_tab]
    else
      render 'overview'
    end
  end

  def history
    @download_histories = DownloadHistory.all.order(downloaded_at: :desc)
  end

  protected
  def get_provider_types
  	@provider_types = ProviderType.all
  end
  def get_states
  	@states = State.all
  end
  def set_provider_personal_informations
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])
    @practice_informations = @provider_personal_information.provider_attest.practice_informations
  end

  def redirect_to_auto_verify
    if current_setting.dcs?
      redirect_to auto_verifies_path and return
    end
  end
end

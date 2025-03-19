class Mhc::ClientPortalController < ApplicationController
  # before_action :set_provider_personal_informations, only: [:show, :edit, :update]
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
    @csv_headers = @csv_data.first  # Store headers separately
    @csv_data = @csv_data.drop(1)   # Remove the first row from the data

  end

  def process_csv
    uploaded_file = params[:file]

    if uploaded_file.present?
      max_size_kb = 4 # Maximum file size in KB
      file_size_kb = uploaded_file.size.to_f / 1024 # Convert bytes to KB

      if file_size_kb > max_size_kb
        flash[:alert] = "File size exceeds the limit of #{max_size_kb}KB."
        redirect_to upload_csv_mhc_client_portal_index_path and return
      end

      csv_data = []

      begin
        csv_text = uploaded_file.read
        csv_data = CSV.parse(csv_text, headers: true)
      rescue StandardError => e
        flash[:alert] = "Invalid CSV format. Please upload a valid file."
        redirect_to upload_csv_mhc_client_portal_index_path and return
      end

      session[:csv_data] = csv_data.to_a
    else
      flash[:alert] = "No file selected."
    end

    redirect_to upload_csv_mhc_client_portal_index_path
  end


  def clear_csv
    session.delete(:csv_data)
    flash[:notice] = "CSV data cleared successfully"
    redirect_to upload_csv_mhc_client_portal_index_path
  end

  def download_csv
    csv_data = session[:csv_data]

    if csv_data.present?
      csv_content = CSV.generate(headers: true) do |csv|
        csv << csv_data.first
        csv_data[1..].each { |row| csv << row }
      end

      # Generate filename
      file_name = "report_#{Date.today}.csv"
      file_path = Rails.root.join('public', 'csv_reports', file_name)

      # Ensure the directory exists
      FileUtils.mkdir_p(File.dirname(file_path))

      # Save the file
      begin
        File.write(file_path, csv_content)
      rescue StandardError => e
        flash[:alert] = "Failed to save CSV file."
        redirect_to upload_csv_mhc_client_portal_index_path and return
      end

      DownloadHistory.create(
        file_name: file_name,
        downloaded_at: Time.now,
        user_id: current_user.id # Assuming authentication is present
      )

      send_data csv_content, filename: file_name, type: "text/csv"
    else
      flash[:alert] = "No CSV data to download"
      redirect_to upload_csv_mhc_client_portal_index_path
    end
  end

  # download the files from the request history
  def download_existing_file
    file_name = params[:file_name]
    file_path = Rails.root.join('public', 'csv_reports', file_name)

    if File.exist?(file_path)
      send_file file_path, type: 'text/csv', disposition: 'attachment', filename: file_name
    else
      flash[:alert] = "File not found."
      redirect_to history_mhc_client_portal_index_path
    end
  end

  # def show
  #   if params[:page_tab]
  #     render params[:page_tab]
  #   else
  #     render 'overview'
  #   end
  # end

  def show
    @download_histories = DownloadHistory.all.order(downloaded_at: :desc)
  end

  protected
  def get_provider_types
  	@provider_types = ProviderType.all
  end
  def get_states
  	@states = State.all
  end

  # def set_provider_personal_informations
  #   @provider_personal_information = ProviderPersonalInformation.find(params[:id])
  #   @practice_informations = @provider_personal_information.provider_attest.practice_informations
  # end

  def redirect_to_auto_verify
    if current_setting.dcs?
      redirect_to auto_verifies_path and return
    end
  end
end

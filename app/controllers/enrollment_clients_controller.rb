class EnrollmentClientsController < ApplicationController
  before_action :set_providers, only: [:index, :download_documents, :show, :reports, :notifications]
  before_action :set_provider, only: [:show]
  before_action :set_incomplete_providers, only: [:show, :index, :reports, :notifications]
  def index; end

  def show
    if params[:mode].present?
      render params[:mode]
    end
  end

  def reports;end

  def notifications


    @provider = if params[:provider_id]
      Provider.find(params[:provider_id])
    else
      @incomplete_providers.first
    end

    if @provider
      @show_missing_fields = @provider.show_missing_fields?
      @provider.build_licenses if @provider.licenses.nil?
    end
  end

  def providers_to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Provider Status", "Client", "Location", "First Name", "Middle Name", "Last Name", "Practitioner Type", "NPI", "Practitioner SSN"]

      @providers.each do |provider|
        csv << [
          "",
          provider&.client&.group_name,
          provider&.location&.dco_name,
          provider&.first_name,
          provider&.middle_name,
          provider&.last_name,
          provider&.practitioner,
          provider&.npi,
          provider&.ssn
        ]
      end
    end
  end

  def download_documents
    respond_to do |format|
      format.csv { send_data providers_to_csv, filename: "Providers.csv" }
    end
  end

  protected

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def set_providers
    @providers = Provider.search_by_params(params).paginate(per_page: 50, page: params[:page] || 1)
  end

  def set_incomplete_providers
    @incomplete_providers ||= Provider.search_by_params(params).with_missing_required_attributes.paginate(per_page: 50, page: params[:page] || 1)
  end
end
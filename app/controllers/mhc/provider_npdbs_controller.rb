class Mhc::ProviderNpdbsController < ApplicationController
	before_action :set_provider_npdb, only: [:update]

	def index
    @provider_npdbs = ProviderNpdb.all
  end

  def create
    @provider_npdb = ProviderNpdb.new(provider_npdb_params)

    if @provider_npdb.save
      redirect_to mhc_verification_platform_path(page_tab: 'npdb_record',id: params[:provider_npdb][:provider_attest_id]), notice: 'Npdb detail saved successfully.'
    else
      Rails.logger.error @provider_npdb.errors.full_messages.join(", ")
      redirect_to mhc_verification_platform_path(page_tab: 'npdb_record',id: params[:provider_npdb][:provider_attest_id]), alert: 'Failed to save npdb detail.'
    end
  end

  def update
   @provider_npdb.assign_attributes(provider_npdb_params)

    if @provider_npdb.save
      redirect_to mhc_verification_platform_path(page_tab: 'npdb',id: params[:provider_npdb][:provider_attest_id]), notice: 'Npdb detail updated successfully.'
    else
      Rails.logger.error @provider_npdb.errors.full_messages.join(", ")
      redirect_to mhc_verification_platform_path(page_tab: 'npdb_record',id: params[:provider_npdb][:provider_attest_id]), alert: 'Failed to save npdb detail.'
    end
  end

  def run_npdb
    personal_info = ProviderPersonalInformation.find(params[:personal_info_id])
    provider_npdb = ProviderNpdb.find(params[:id])
    provider      = provider_npdb.provider

    result = Npdb::QueryService.new(provider, provider_npdb).call

    provider_npdb.update!(
      status:        result[:status],
      submit_date:   result[:submit_date],
      response_date: result[:response_date],
      comments:      result[:comments]
    )

    redirect_to mhc_provider_npdb_path(provider_npdb),
                notice: 'NPDB query completed'
  rescue => e
    provider_npdb.update!(status: 'failed', comments: e.message)
    redirect_back fallback_location: root_path, alert: e.message
  end

  private

  def set_provider_npdb
    @provider_npdb = ProviderNpdb.find(params[:id])
  end

  # Strong parameters for security
  def provider_npdb_params
    params.require(:provider_npdb).permit(
    	:provider_attest_id,
    	:caqh_provider_attest_id,
    	:practitioner_type,
    	:individual_identification_number_1,
    	:individual_identification_number_2,
    	:individual_identification_number_3,
    	:individual_identification_number_4,
    	:show_on_tickler,
    	:status,
    	:submit_date,
    	:response_date,
    	:comments
    )
  end
end
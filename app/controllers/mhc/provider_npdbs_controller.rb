class Mhc::ProviderNpdbsController < ApplicationController
	before_action :set_provider_npdb, only: [:update]

	def index
    @provider_npdbs = ProviderNpdb.all
  end

  def create
    @provider_npdb = ProviderNpdb.new(provider_npdb_params)

    if @provider_npdb.save
      redirect_to mhc_verification_platform_path(page_tab: 'npdb',id: params[:provider_npdb][:provider_attest_id]), notice: 'Npdb detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'npdb_record',id: params[:provider_npdb][:provider_attest_id]), alert: 'Failed to save npdb detail.'
    end
  end

  def update
   @provider_npdb.assign_attributes(provider_npdb_params)

    if @provider_npdb.save
      redirect_to mhc_verification_platform_path(page_tab: 'npdb',id: params[:provider_npdb][:provider_attest_id]), notice: 'Npdb detail updated successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'npdb_record',id: params[:provider_npdb][:provider_attest_id]), alert: 'Failed to save npdb detail.'
    end
  end

  private

  def set_provider_npdb
    @provider_npdb = ProviderEducation.find(params[:id])
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
class Mhc::ProviderDeasController < ApplicationController
  before_action :set_provider_dea, only: [:update]
  
  def create
    provider_dea = ProviderDea.new(provider_dea_params)
    if params[:provider_dea][:full_schedule] == 'Yes'
      provider_dea.schedules_held = ["2", "2N", "3", "3N", "4", "5"]
    end
    if provider_dea.save
      redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_dea][:provider_attest_id]),
                  notice: 'Record created successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_dea][:provider_attest_id]),
                  alert: 'Failed to create record.'
    end
  end
  

  def update
    if params[:provider_dea][:full_schedule] == 'Yes'
      @provider_dea.schedules_held = ["2", "2N", "3", "3N", "4", "5"]
    end
    @provider_dea.assign_attributes(provider_dea_params)

    if @provider_dea.update
      @provider_deas = @provider.provider_deas
      @show_rva_information = @provider_deas.exists?
      redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_dea][:provider_attest_id]), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_dea][:provider_attest_id]), notice: 'Failed to create record.'
    end
  end

  def destroy
    @provider_dea = ProviderDea.find(params[:provider_dea_id])
    if @provider_dea.destroy
      redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_attest_id]), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'registration', id: params[:provider_attest_id]), notice: 'Failed to create record.'
    end
  end

  private
  def provider_dea_params
    params.require(:provider_dea).permit(
      :caqh_provider_deaid, :provider_attest_id, :dea_number, :state, :expiration_date,
      :caqh_provider_attest_id, :dea_license_limitation_flag, :dea_license_limitation_explanation,
      :no_dea_explanation, :application_date, :show_on_tickler, :full_schedule, schedules_held: [])
  end

  def set_provider_dea
    @provider_dea = ProviderDea.find(params[:id])
  end
end

class Mhc::ProviderPersonalInformationAppTrackingsController < ApplicationController
  before_action :set_provider_personal_information_app_tracking, only: [:edit, :update]

  def create
    @provider_personal_information_app_tracking = ProviderPersonalInformationAppTracking.new(provider_personal_information_app_tracking_params)
    if @provider_personal_information_app_tracking.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'app_tracking',
        id: @provider_personal_information_app_tracking.provider_personal_information.provider_attest_id
      ), notice: 'Data saved successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'app_tracking_record',
        id: @provider_personal_information_app_tracking.provider_personal_information.provider_attest_id
      ), alert: 'Failed to save data.'
    end
  end

  def update
    @provider_personal_information_app_tracking.assign_attributes(provider_personal_information_app_tracking_params)
    
    if @provider_personal_information_app_tracking.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'app_tracking',
        id: @provider_personal_information_app_tracking.provider_personal_information.provider_attest_id
      ), notice: 'Update saved successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'app_tracking_record',
        id: @provider_personal_information_app_tracking.provider_personal_information.provider_attest_id
      ), alert: 'Failed to update.'
    end
  end

  private

  def set_provider_personal_information_app_tracking
    @provider_personal_information_app_tracking = ProviderPersonalInformationAppTracking.find(params[:id])
  end

  def provider_personal_information_app_tracking_params
    params.require(:provider_personal_information_app_tracking).permit(:owner, :file_status, :application_type, :application_receipt_date, 
  :application_submitted_date, :verification_complete_date, :file_return_to_client_date, 
  :application_receive_complete_date, :application_comment, :other_comment, :provider_personal_information_id, 
  :expedite, master_issues: [], master_reviews: [])
  end
end

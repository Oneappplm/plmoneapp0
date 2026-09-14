class Mhc::ProviderPersonalInformationSamRecordsController < ApplicationController
  before_action :set_provider_personal_information, only: [:create, :auto_create]
  before_action :set_provider_personal_information_sam_record, only: [:show]

  def create
    provider_personal_information_sam_record = @provider_personal_information.provider_personal_information_sam_records.new(
      provider_personal_information_sam_record_params
    )
    if provider_personal_information_sam_record.save
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab],id: @provider_personal_information.provider_attest_id), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab],id:  @provider_personal_information.provider_attest_id), notice: 'Failed to create record.'
    end
  end

  def auto_create
    provider_personal_information_sam_record = @provider_personal_information.provider_personal_information_sam_records.find_or_initialize_by(
      first_name: @provider_personal_information.first_name,
      last_name: @provider_personal_information.last_name,
      middle_name: @provider_personal_information.middle_name,
      suffix: @provider_personal_information.suffix,
      ssn: @provider_personal_information.ssn,
      is_primary: true
    )
    if provider_personal_information_sam_record.save
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab],id: @provider_personal_information.provider_attest_id), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab],id: @provider_personal_information.provider_attest_id), notice: 'Failed to create record.'
    end
  end
  
  def destroy
    @provider_personal_information_sam_record = ProviderPersonalInformationSamRecord.find(params[:id])
  
    # Ensure provider_personal_information is loaded
    @provider_personal_information = @provider_personal_information_sam_record.provider_personal_information
  
    if @provider_personal_information_sam_record.destroy
      redirect_to mhc_verification_platform_path(id: @provider_personal_information.id, page_tab: 'sam'), notice: 'Record deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(id: @provider_personal_information.id, page_tab: 'sam'), alert: 'Failed to delete record.'
    end
  end
  

  private
  def provider_personal_information_sam_record_params
    params.require(:provider_personal_information_sam_record).permit(
      :first_name, :middle_name, :last_name, :suffix, :ssn, :is_primary, :provider_personal_information_id)
  end

  def set_provider_personal_information_sam_record
    @provider_personal_information_sam_record = ProviderPersonalInformationSamRecord.find(params[:id])
  end

  def set_provider_personal_information
    @provider_personal_information = ProviderPersonalInformation.find(provider_personal_information_sam_record_params[:provider_personal_information_id])
  end
end

class Mhc::ProviderPersonalInformationSamRvaRecordsController < ApplicationController
  before_action :set_provider_personal_information_sam_rva_record, only: [:update]
  def create
    provider_personal_information_sam_rva_record = ProviderPersonalInformationSamRvaRecord.new(
      provider_personal_information_sam_rva_record_params
    )

    if provider_personal_information_sam_rva_record.save
      redirect_to mhc_verification_platform_path(page_tab: 'sam_record', provider_personal_information_sam_record_id: params[:provider_personal_information_sam_rva_record][:provider_personal_information_sam_record_id], id: params[:provider_personal_information_sam_rva_record][:provider_attest_id]), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab], provider_personal_information_sam_record_id: params[:provider_personal_information_sam_rva_record][:provider_personal_information_sam_record_id], id: params[:provider_personal_information_sam_rva_record][:provider_attest_id]), notice: 'Failed to create record.'
    end
  end

  def update
    @provider_personal_information_sam_rva_record.assign_attributes(provider_personal_information_sam_rva_record_params)

    if @provider_personal_information_sam_rva_record.save
      redirect_to mhc_verification_platform_path(page_tab: 'sam_record', provider_personal_information_sam_record_id: params[:provider_personal_information_sam_rva_record][:provider_personal_information_sam_record_id], id: params[:provider_personal_information_sam_rva_record][:provider_attest_id]), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab], provider_personal_information_sam_record_id: params[:provider_personal_information_sam_rva_record][:provider_personal_information_sam_record_id], id: params[:provider_personal_information_sam_rva_record][:provider_attest_id]), notice: 'Failed to create record.'
    end
  end

  # Lacking the webcrawler
  def auto_create
    provider_personal_information_sam_rva_record = ProviderPersonalInformationSamRvaRecord.create(
      search_result: 'no_match',
      source_date: DateTime.now,
      verification_date: DateTime.now,
      provider_personal_information_sam_record_id: params[:provider_personal_information_sam_record_id],
      exclusion_type: 'None'
    )

    redirect_to mhc_verification_platform_path(page_tab: 'sam_record', provider_personal_information_sam_record_id: params[:provider_personal_information_sam_record_id], id: params[:id]), notice: 'Created record successfully.'
  end

  private
  def provider_personal_information_sam_rva_record_params
    params.require(:provider_personal_information_sam_rva_record).permit(
      :search_result, :exclusion_type, :provider_personal_information_sam_record_id, :verification_sanctions,
      :comments, :source_date, :verification_date, :supporting_documentation)
  end

  def set_provider_personal_information_sam_rva_record
    @provider_personal_information_sam_rva_record = ProviderPersonalInformationSamRvaRecord.find(params[:id])
  end
end

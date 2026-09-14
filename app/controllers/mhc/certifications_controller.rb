class Mhc::CertificationsController < ApplicationController
  before_action :set_certification, only: [:update, :destroy]

  def index
    @certifications = Certification.all
  end

  def create
    @certification = Certification.new(certification_params)
    
    if @certification.save
      redirect_to mhc_verification_platform_path(page_tab: 'certifications', id: params[:certification][:provider_attest_id]), notice: 'Certification saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'certifications', id: params[:certification][:provider_attest_id]), alert: 'Failed to save certification.'
    end
  end  

  def update
    @certification.assign_attributes(certification_params)

    if @certification.save
      redirect_to mhc_verification_platform_path(page_tab: 'certifications', id: @certification.provider_attest_id), notice: 'Certification updated successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'certifications', id: certification_params[:provider_attest_id]), alert: 'Failed to update certification.'
    end
  end

  def destroy
    if @certification.destroy
      redirect_to mhc_verification_platform_path(page_tab: 'certifications', id: @certification.provider_attest_id), notice: 'Certification deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'certifications', id: @certification.provider_attest_id), alert: 'Failed to delete certification.'
    end
  end

  private

  def set_certification
    @certification = Certification.find(params[:id])
  end

  def certification_params
    params.require(:certification).permit(
      :certification_type, :issuing_agency, :certification_status, :certification_number,
      :initial_certification_date, :recertification_dates, :certification_expiration_date,
      :does_not_expire, :comments, :show_on_tickler,
      :caqh_provider_attest_id, :provider_attest_id
    )
  end  
end

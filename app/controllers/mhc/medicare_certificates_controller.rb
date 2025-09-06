class Mhc::MedicareCertificatesController < ApplicationController
  before_action :set_medicare_certificate, only: [:update, :destroy]

  def index
    @medicare_certificates = MedicareCertificate.all
  end

  def create
    @medicare_certificate = MedicareCertificate.new(medicare_certificate_params)

    if @medicare_certificate.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_cert',
        id: params[:medicare_certificate][:provider_attest_id],
        from_ppi_link: true
      ), notice: 'Medicare certificate detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_cert',
        id: params[:medicare_certificate][:provider_attest_id],
        from_ppi_link: true
      ), alert: 'Failed to save medicare certificate detail.'
    end
  end

  def update
    @medicare_certificate.assign_attributes(medicare_certificate_params)

    if @medicare_certificate.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_cert',
        id: params[:medicare_certificate][:provider_attest_id],
        from_ppi_link: true
      ), notice: 'Medicare certificate detail updated successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_cert',
        id: params[:medicare_certificate][:provider_attest_id],
        from_ppi_link: true
      ), alert: 'Failed to update medicare certificate detail.'
    end
  end

  def destroy
    if @medicare_certificate.destroy
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_cert',
        id: @medicare_certificate.provider_attest_id
      ), notice: 'Medicare certificate detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_cert',
        id: @medicare_certificate.provider_attest_id
      ), alert: 'Failed to delete medicare certificate detail.'
    end
  end

  private

  def set_medicare_certificate
    @medicare_certificate = MedicareCertificate.find(params[:id])
  end

  def medicare_certificate_params
    params.require(:medicare_certificate).permit(
      :id,
      :provider_attest_id,
      :medicare_number,
      :status,
      :source,
      :source_date,
      :verified_by,
      :verified_date,
      :review_criteria
    )
  end
end

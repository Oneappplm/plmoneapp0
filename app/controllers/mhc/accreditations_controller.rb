class Mhc::AccreditationsController < ApplicationController
  before_action :set_accreditation, only: [:update, :destroy]

  def index
    @accreditations = Accreditation.all
  end

  def create
    @accreditation = Accreditation.new(accreditation_params)

    if @accreditation.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'accreditation',
        id: params[:accreditation][:provider_attest_id],
        from_ppi_link: true
      ), notice: 'Accreditation detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'accreditation',
        id: params[:accreditation][:provider_attest_id],
        from_ppi_link: true
      ), alert: 'Failed to save accreditation detail.'
    end
  end

  def update
    @accreditation.assign_attributes(accreditation_params)

    if @accreditation.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'accreditation',
        id: params[:accreditation][:provider_attest_id],
        from_ppi_link: true
      ), notice: 'Accreditation detail updated successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'accreditation',
        id: params[:accreditation][:provider_attest_id],
        from_ppi_link: true
      ), alert: 'Failed to update accreditation detail.'
    end
  end

  def destroy
    if @accreditation.destroy
      redirect_to mhc_verification_platform_path(
        page_tab: 'accreditation',
        id: @accreditation.provider_attest_id,
        from_ppi_link: true
      ), notice: 'Accreditation detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'accreditation',
        id: @accreditation.provider_attest_id,
        from_ppi_link: true
      ), alert: 'Failed to delete accreditation detail.'
    end
  end

  private

  def set_accreditation
    @accreditation = Accreditation.find(params[:id])
  end

  def accreditation_params
    params.require(:accreditation).permit(
      :id,
      :provider_attest_id,
      :accrediting_body,
      :initial_review_date,
      :last_review_date,
      :certification_number,
      :expiration_date,
      :does_not_expire,
      :primary_accrediting_body,
      :corrective_action_plan,
      :date_initiated,
      :date_completed,
      :comments,
      :show_on_tickler
    )
  end
end

class Mhc::MedicareParticipationsController < ApplicationController
  before_action :set_medicare_participation, only: [:update, :destroy]

  def index
    @medicare_participations = MedicareParticipation.all
  end

  def create
    @medicare_participation = MedicareParticipation.new(medicare_participation_params)

    if @medicare_participation.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_part',
        id: params[:medicare_participation][:provider_attest_id],
        from_ppi_link: true
      ), notice: 'Medicare participation detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_part',
        id: params[:medicare_participation][:provider_attest_id],
        from_ppi_link: true
      ), alert: 'Failed to save medicare participation detail.'
    end
  end

  def update
    @medicare_participation.assign_attributes(medicare_participation_params)

    if @medicare_participation.save
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_part',
        id: params[:medicare_participation][:provider_attest_id],
        from_ppi_link: true
      ), notice: 'Medicare participation detail updated successfully.'
    else
      redirect_to mhc_verification_platform_path(
        page_tab: 'medicare_part',
        id: params[:medicare_participation][:provider_attest_id],
        from_ppi_link: true
      ), alert: 'Failed to update medicare participation detail.'
    end
  end

  def destroy
    if @medicare_participation.destroy
      redirect_to mhc_verification_platform_path(page_tab: 'medicare_part', id: @medicare_participation.provider_attest_id),
                  notice: 'Medicare participation detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'medicare_part', id: @medicare_participation.provider_attest_id),
                  alert: 'Failed to delete medicare participation detail.'
    end
  end

  private

  def set_medicare_participation
    @medicare_participation = MedicareParticipation.find(params[:id])
  end

  def medicare_participation_params
    params.require(:medicare_participation).permit(
      :id,
      :provider_attest_id,
      :medicare_participating,
      :status,
      :source,
      :source_date,
      :verified_date,
      :verified_by,
      :review_criteria
    )
  end
end

class Mhc::ProviderPersonalInformationReinstatementsController < ApplicationController
  before_action :set_provider_personal_information, only: [:create]
  before_action :set_provider_personal_information_reinstatement, only: [:edit, :update, :destroy]

  def create
    provider_personal_information_reinstatement = @provider_personal_information.provider_personal_information_reinstatements.new(
      provider_personal_information_reinstatement_params
    )
    if provider_personal_information_reinstatement.save
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab],id: @provider_personal_information.provider_attest_id), notice: 'Created record successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab],id:  @provider_personal_information.provider_attest_id), notice: 'Failed to create record.'
    end
  end

  def edit
    # ye action form ke liye render karega automatically
  end

  # UPDATE
  def update
    if @provider_personal_information_reinstatement.update(provider_personal_information_reinstatement_params)
      redirect_to mhc_verification_platform_path(page_tab: params[:page_tab], id: @provider_personal_information_reinstatement.provider_personal_information.provider_attest_id), notice: 'Record updated successfully.'
    else
      render :edit, alert: 'Failed to update record.'
    end
  end

  # DELETE
  def destroy
    provider_attest_id = @provider_personal_information_reinstatement.provider_personal_information.provider_attest_id
    @provider_personal_information_reinstatement.destroy
    redirect_to mhc_verification_platform_path(page_tab: 'oig', id: provider_attest_id), notice: 'Record deleted successfully.'
  end

  private
  def provider_personal_information_reinstatement_params
    params.require(:provider_personal_information_reinstatement).permit(
      :state, :general, :exclusion_type, :process_date, :specialty, :reinstatement_date, :provider_personal_information_id)
  end

  def set_provider_personal_information_reinstatement
    @provider_personal_information_reinstatement = ProviderPersonalInformationReinstatement.find(params[:id])
  end

  def set_provider_personal_information
    @provider_personal_information = ProviderPersonalInformation.find(provider_personal_information_reinstatement_params[:provider_personal_information_id])
  end
end

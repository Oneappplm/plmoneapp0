class Mhc::ProviderPersonalInformationOpmcsController < ApplicationController
  before_action :set_provider_personal_information
  before_action :set_provider_opmc

  def create
    if @provider_opmc.update(provider_opmc_params)
      redirect_back fallback_location: mhc_verification_platform_path(@provider_personal_information),
                    notice: "OPMC information saved successfully."
    else
      redirect_back fallback_location: mhc_verification_platform_path(@provider_personal_information),
                    alert: @provider_opmc.errors.full_messages.to_sentence
    end
  end

  def update
    if @provider_opmc.update(provider_opmc_params)
      redirect_back fallback_location: mhc_verification_platform_path(@provider_personal_information),
                    notice: "OPMC information updated successfully."
    else
      redirect_back fallback_location: mhc_verification_platform_path(@provider_personal_information),
                    alert: @provider_opmc.errors.full_messages.to_sentence
    end
  end

  private

  def set_provider_personal_information
    @provider_personal_information =
      ProviderPersonalInformation.find(params[:provider_personal_information_id])
  end

  def set_provider_opmc
    @provider_opmc =
      @provider_personal_information.provider_opmc ||
      @provider_personal_information.build_provider_opmc
  end

  def provider_opmc_params
    params.require(:provider_personal_information_opmc).permit(
      :source_date,
      :verification_date,
      :search_result,
      :effective_date,
      :supporting_document
    )
  end
end
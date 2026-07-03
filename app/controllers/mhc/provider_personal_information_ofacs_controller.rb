class Mhc::ProviderPersonalInformationOfacsController < ApplicationController
  before_action :set_provider_personal_information
  before_action :set_provider_ofac

  def create
    save_ofac("OFAC information saved successfully.")
  end

  def update
    save_ofac("OFAC information updated successfully.")
  end

  private

  def set_provider_personal_information
    @provider_personal_information =
      ProviderPersonalInformation.find(params[:provider_personal_information_id])
  end

  def set_provider_ofac
    @provider_ofac =
      @provider_personal_information.provider_ofac ||
      @provider_personal_information.build_provider_ofac
  end

  def save_ofac(message)
    if @provider_ofac.update(provider_ofac_params)
      redirect_to mhc_verification_platform_path(
        @provider_personal_information.provider_attest_id,
        page_tab: "ofac"
      ), notice: message
    else
      redirect_back fallback_location: mhc_verification_platform_path(
        @provider_personal_information.provider_attest_id,
        page_tab: "ofac"
      ), alert: @provider_ofac.errors.full_messages.to_sentence
    end
  end

  def provider_ofac_params
    params.require(:provider_personal_information_ofac).permit(
      :source_date,
      :verification_date,
      :search_result,
      :effective_date,
      :supporting_document
    )
  end
end
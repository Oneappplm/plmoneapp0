class Mhc::ProviderPersonalInformationOmigsController < ApplicationController
  before_action :set_provider_personal_information
  before_action :set_provider_personal_information_omig

  def create
    save_omig('OMIG information saved successfully.')
  end

  def update
    save_omig('OMIG information updated successfully.')
  end

  private

  def set_provider_personal_information
    @provider_personal_information =
      ProviderPersonalInformation.find(params[:provider_personal_information_id])
  end

  def set_provider_personal_information_omig
    @provider_omig =
      @provider_personal_information.provider_personal_information_omig ||
      @provider_personal_information.build_provider_personal_information_omig
  end

  def save_omig(message)
    if @provider_omig.update(provider_omig_params)
      redirect_back fallback_location: mhc_verification_platform_path(@provider_personal_information, page_tab: 'omig'),
                    notice: message
    else
      redirect_back fallback_location: mhc_verification_platform_path(@provider_personal_information, page_tab: 'omig'),
                    alert: @provider_omig.errors.full_messages.to_sentence
    end
  end

  def provider_omig_params
    params.require(:provider_personal_information_omig).permit(
      :source_date,
      :verification_date,
      :search_result,
      :effective_date,
      :supporting_document
    )
  end
end
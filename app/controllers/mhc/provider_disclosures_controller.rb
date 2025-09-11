class Mhc::ProviderDisclosuresController < ApplicationController
  def new
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])
    @provider_attest = @provider_personal_information.provider_attest
    8.times { @provider_attest.provider_disclosures.build } if @provider_attest.provider_disclosures.empty?
  end
  
  def create
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])
    provider_attest = @provider_personal_information.provider_attest

    disclosures_params = provider_attest_params[:provider_disclosures_attributes]

    disclosures_params&.each do |_idx, disclosure_attrs|
      if disclosure_attrs[:id].present?
        # Try to find existing record
        disclosure = provider_attest.provider_disclosures.where(id: disclosure_attrs[:id]).first
        if disclosure
          disclosure.update(disclosure_attrs.except(:id))
        else
          # If ID doesn’t belong, create new
          provider_attest.provider_disclosures.create(disclosure_attrs.except(:id))
        end
      else
        # New record
        provider_attest.provider_disclosures.create(disclosure_attrs)
      end
    end

    redirect_to mhc_verification_platform_path(page_tab: 'disclosures', id: provider_attest.id),
                notice: 'Saved disclosure details.'
  end

  private

  def provider_attest_params
    params.require(:provider_attest).permit(
      provider_disclosures_attributes: [
        :id, :disclosure_question_disclosure_summary, :disclosure_answer_flag, 
        :disclosure_explanation, :disclosure_date, :_destroy
      ]
    )
  end
end

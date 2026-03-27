class Mhc::ProviderDisclosuresController < ApplicationController
  def create
    @provider_personal_information = ProviderPersonalInformation.find(params[:id])
    provider_attest = @provider_personal_information.provider_attest

    disclosures_params = provider_attest_params[:provider_disclosures_attributes]

    disclosures_params&.each do |_idx, attrs|
      # --- convert "true"/"false" strings to real booleans or nil ---
      if attrs.key?(:disclosure_answer_flag)
        attrs[:disclosure_answer_flag] =
          case attrs[:disclosure_answer_flag]
          when true, 'true', '1'   then true
          when false, 'false', '0' then false
          else nil
          end
      end

      if attrs[:id].present?
        disclosure = provider_attest.provider_disclosures.find_or_initialize_by(id: attrs[:id])
        # keep created date in disclosure_date when updating
        attrs[:disclosure_date] = disclosure.created_at if disclosure.persisted?
        disclosure.update(attrs.except(:id))
      else
        # new record: set disclosure_date to created_at after save
        d = provider_attest.provider_disclosures.build(attrs.except(:id))
        d.save
        d.update_column(:disclosure_date, d.created_at)
      end
    end

    redirect_to mhc_verification_platform_path(page_tab: 'disclosures', id: provider_attest.id),
                notice: 'Saved disclosure details.'
  end

  private

  def provider_attest_params
    params.require(:provider_attest).permit(
      provider_disclosures_attributes: [
        :id,
        :disclosure_question_disclosure_summary,
        :disclosure_answer_flag,
        :disclosure_explanation,
        :disclosure_date,
        :_destroy
      ]
    )
  end
end

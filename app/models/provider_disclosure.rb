class ProviderDisclosure < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDisclosureID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
  validates :disclosure_explanation, presence: true, if: -> { disclosure_answer_flag == false }

  before_validation :set_provider_attest

  private

  def set_provider_attest
    if provider_attest_id.blank? && provider_personal_information&.provider_attest_id.present?
      self.provider_attest_id = provider_personal_information.provider_attest_id
    end
  end

end

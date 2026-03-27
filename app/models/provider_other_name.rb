class ProviderOtherName < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderOtherNameID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest, if: -> { provider_attest_id.blank? }
  private


  def set_provider_attest
    # Do nothing if association already set (nested attributes handles it)
    return if provider_attest.present?

    # Only fallback logic if absolutely required
    self.provider_attest = ProviderAttest.find_by(id: provider_attest_id) if provider_attest_id.present?
  end
end

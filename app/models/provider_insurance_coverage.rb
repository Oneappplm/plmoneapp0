class ProviderInsuranceCoverage < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID', 'ProviderInsuranceID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest

  private

  def set_provider_attest
    return if caqh_provider_attest_id.blank?

    self.provider_attest = ProviderAttest.find_by(caqh_provider_attest_id: caqh_provider_attest_id)
    Rails.logger.info "ProviderAttest set to: #{self.provider_attest.inspect}"
  end
end

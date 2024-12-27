class ProviderCd < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderCDSID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest
  private

  def set_provider_attest
    if caqh_provider_attest_id.present?
      self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
    end
  
    if self.provider_attest.nil?
      errors.add(:provider_attest, "could not be found. Please check the CAQH Provider Attest ID.")
    end
  end  
end

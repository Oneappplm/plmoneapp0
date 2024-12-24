class ProviderDea < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDEAID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest
  private

  def set_provider_attest
    if caqh_provider_attest_id.present?
      self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
    end
  
    unless self.provider_attest
      errors.add(:provider_attest, "must be associated with a valid ProviderAttest")
    end
  end  
end

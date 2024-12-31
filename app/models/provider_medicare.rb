class ProviderMedicare < ApplicationRecord

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicareID']

  belongs_to :provider_attest, foreign_key: :provider_attest_id

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest
  private

  def set_provider_attest
    if self.caqh_provider_attest_id.present?
      self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
    end
  end 
end

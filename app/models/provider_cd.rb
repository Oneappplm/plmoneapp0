class ProviderCd < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderCDSID']

  belongs_to :provider_attest

  has_many :rva_informations, dependent: :destroy

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest
  private

  def set_provider_attest
    return if provider_attest_id.present?
    self.provider_attest = ProviderAttest.find_by(caqh_provider_attest_id: caqh_provider_attest_id)
  end
end


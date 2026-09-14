class ProviderHospitalPrivilege < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderHospitalID']

  belongs_to :provider_attest

  has_many :provider_hospital_associates

  validates :provider_attest_id, presence: true

  before_validation :set_provider_attest
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end
end

class ProviderHospitalAssociate < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderHospitalAssociateID','ProviderHospitalID']

  belongs_to :provider_attest
  belongs_to :provider_hospital_privilege

  validates :provider_attest_id, presence: true
  validates :provider_hospital_privilege_id, presence: true

  before_validation :set_provider_attest
  before_validation :set_provider_hospital_privilege

  private
  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end

  def set_provider_hospital_privilege
    self.provider_hospital_privilege = ProviderHospitalPrivilege.where(caqh_provider_hospital_id: self.caqh_provider_hospital_id).last
  end
end

class ProviderHospitalAssociate < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_hospital_associate_id,:provider_hospital_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderHospitalAssociateID','ProviderHospitalID']

  belongs_to :provider_attest
  belongs_to :provider_hospital_privilege, foreign_key: [:provider_attest_id,:provider_hospital_id]

  validates :provider_attest_id, presence: true
  validates :provider_hospital_id, presence: true
end

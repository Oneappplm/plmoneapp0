class ProviderHospitalPrivilege < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_hospital_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderHospitalID']

  belongs_to :provider_attest

  has_many :provider_hospital_associates, foreign_key: [:provider_attest_id,:provider_hospital_id]

  validates :provider_attest_id, presence: true
end

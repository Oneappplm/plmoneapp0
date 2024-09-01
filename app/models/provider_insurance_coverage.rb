class ProviderInsuranceCoverage < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_insurance_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderInsuranceID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

class ProviderCertification < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_certification_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderCertificationID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

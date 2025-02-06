class ProviderReference < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_reference_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderReferenceID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

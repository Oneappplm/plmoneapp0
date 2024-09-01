class ProviderDegree < ApplicationRecord
  self.primary_key = [:provider_attest_id, :provider_degree_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDegreeID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

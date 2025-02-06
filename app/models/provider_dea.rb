class ProviderDea < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_deaid]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDEAID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

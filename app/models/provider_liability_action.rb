class ProviderLiabilityAction < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_liability_action_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderLiabilityActionID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

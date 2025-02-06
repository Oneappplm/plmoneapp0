class ProviderAdverseAction < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_adverse_action_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderAdverseActionID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
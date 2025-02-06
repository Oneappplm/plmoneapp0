class ProviderCriminalAction < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_criminal_action_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderCriminalActionID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

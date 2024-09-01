class ProviderOtherInterest < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_other_interest_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderOtherInterestID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

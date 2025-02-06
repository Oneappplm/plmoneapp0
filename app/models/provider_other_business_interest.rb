class ProviderOtherBusinessInterest < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_other_business_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderOtherBusinessID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end
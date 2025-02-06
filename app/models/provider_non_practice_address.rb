class ProviderNonPracticeAddress < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_address_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderAddressID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

class ProviderDisclosure < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_disclosure_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderDisclosureID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

class ProviderIdentificationNumber < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_identifier_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderIdentifierID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

class ProviderAssociate < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_associate_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderAssociateID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

class ProviderCd < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_cdsid]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderCDSID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

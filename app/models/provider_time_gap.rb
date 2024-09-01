class ProviderTimeGap < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_time_gap_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderTimeGapID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

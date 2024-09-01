class ProviderWorkHistory < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_work_history_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderWorkHistoryID']

  belongs_to :provider_attest

  validates :provider_attest_id, presence: true
end

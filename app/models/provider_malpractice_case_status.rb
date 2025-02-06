class ProviderMalpracticeCaseStatus < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_malpractice_claim_status_id,:provider_malpractice_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMalpracticeClaimStatusID','ProviderMalpracticeID']

  belongs_to :provider_attest
  belongs_to :provider_malpractice_history, foreign_key: [:provider_attest_id,:provider_malpractice_id]

  validates :provider_attest_id, presence: true
end

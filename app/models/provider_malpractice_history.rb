class ProviderMalpracticeHistory < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_malpractice_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMalpracticeID']

  belongs_to :provider_attest

  has_many :provider_malpractice_case_statuses, foreign_key: [:provider_attest_id,:provider_malpractice_id]

  validates :provider_attest_id, presence: true
end

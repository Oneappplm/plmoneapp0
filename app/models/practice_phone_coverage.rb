class PracticePhoneCoverage < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_practice_phone_coverage_id,:provider_practice_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticePhoneCoverageID','ProviderPracticeID']

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: [:provider_attest_id, :provider_practice_id]

  validates :provider_attest_id, presence: true
  validates :provider_practice_id, presence: true
end

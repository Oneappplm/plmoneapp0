class PracticeSpecialty < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_practice_specialty_id,:provider_practice_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticeSpecialtyID','ProviderPracticeID']

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: [:provider_attest_id, :provider_practice_id]

  validates :provider_attest_id, presence: true
  validates :provider_practice_id, presence: true
end

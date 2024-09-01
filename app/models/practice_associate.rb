class PracticeAssociate < ApplicationRecord
  self.primary_key = [:provider_attest_id, :provider_practice_associate_id, :provider_practice_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticeAssociateID','ProviderPracticeID']

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: [:provider_attest_id, :provider_practice_id]

  validates :provider_attest_id, presence: true
  validates :provider_practice_id, presence: true

  has_many :practice_associate_other_questions, foreign_key: [:provider_attest_id, :provider_practice_associate_id, :provider_practice_id]
  has_many :practice_associate_specialties, foreign_key: [:provider_attest_id, :provider_practice_associate_id, :provider_practice_id]
end

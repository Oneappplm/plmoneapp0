class PracticeAssociateSpecialty < ApplicationRecord
  self.primary_key = [:provider_attest_id, :provider_practice_associate_specialty_id, :provider_practice_associate_id, :provider_practice_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticeAssociateSpecialtyID','ProviderPracticeAssociateID','ProviderPracticeID']

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: [:provider_attest_id, :provider_practice_id]
  belongs_to :practice_associate, foreign_key: [:provider_attest_id, :provider_practice_associate_id, :provider_practice_id]

  validates :provider_attest_id, presence: true
  validates :provider_practice_id, presence: true
  validates :provider_practice_associate_id, presence: true
end

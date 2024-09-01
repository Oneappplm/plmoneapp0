class ProviderMedicalCondition < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_medical_condition_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicalConditionID']

  belongs_to :provider_attest

  has_many :provider_medical_condition_providers, foreign_key: [:provider_attest_id,:provider_medical_condition_id]

  validates :provider_attest_id, presence: true
end

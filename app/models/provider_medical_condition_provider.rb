class ProviderMedicalConditionProvider < ApplicationRecord
  self.primary_key = [:provider_attest_id,:provider_medical_condition_provider_id,:provider_medical_condition_id]

  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicalConditionProviderID','ProviderMedicalConditionID']

  belongs_to :provider_attest
  belongs_to :provider_medical_condition, foreign_key: [:provider_attest_id,:provider_medical_condition_id]

  validates :provider_attest_id, presence: true
  validates :provider_medical_condition_id, presence: true
end

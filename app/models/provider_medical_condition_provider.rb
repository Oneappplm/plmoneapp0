class ProviderMedicalConditionProvider < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMedicalConditionProviderID','ProviderMedicalConditionID']

  belongs_to :provider_attest
  belongs_to :provider_medical_condition

  validates :provider_attest_id, presence: true
  validates :provider_medical_condition_id, presence: true

  before_validation :set_provider_attest
  before_validation :set_provider_medical_condition
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end

  def set_provider_medical_condition
    self.provider_medical_condition = ProviderMedicalCondition.where(caqh_provider_medical_condition_id: self.caqh_provider_medical_condition_id).last
  end
end

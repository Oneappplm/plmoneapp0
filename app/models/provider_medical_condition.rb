class ProviderMedicalCondition < ApplicationRecord
  self.primary_key = :provider_medical_condition_id

  belongs_to :provider_attest

  has_many :provider_medical_condition_providers

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_attest.id
  end
end

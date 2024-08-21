class ProviderRaceEthnicity < ApplicationRecord
  self.primary_key = :provider_race_ethnicity_id

  belongs_to :provider_attest

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_attest.id
  end
end

class ProviderAdverseAction < ApplicationRecord
  self.primary_key = :provider_adverse_action_id

  belongs_to :provider_attest

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_attest_id
  end
end

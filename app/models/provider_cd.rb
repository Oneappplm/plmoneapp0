class ProviderCd < ApplicationRecord
  self.primary_key = :provider_cdsid

  belongs_to :provider_attest

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_attest.id
  end
end

class ProviderMalpracticeCaseStatus < ApplicationRecord
  self.primary_key = :provider_malpractice_claim_status_id

  belongs_to :provider_attest
  belongs_to :provider_malpractice_history, foreign_key: :provider_malpractice_id

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_malpractice_history.provider_attest.id
  end
end

class ProviderMalpracticeHistory < ApplicationRecord
  self.primary_key = :provider_malpractice_id

  belongs_to :provider_attest

  has_many :provider_malpractice_case_statuses, foreign_key: :provider_malpractice_id

  validates :provider_attest, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.provider_attest.id
  end
end

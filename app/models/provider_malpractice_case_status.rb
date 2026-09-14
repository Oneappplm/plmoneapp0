class ProviderMalpracticeCaseStatus < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderMalpracticeClaimStatusID','ProviderMalpracticeID']

  belongs_to :provider_attest
  belongs_to :provider_malpractice_history

  validates :provider_attest_id, presence: true
  validates :provider_malpractice_history_id, presence: true

  before_validation :set_provider_attest
  before_validation :set_provider_malpractice_history
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end

  def set_provider_malpractice_history
    self.provider_malpractice_history = ProviderMalpracticeHistory.where(caqh_provider_malpractice_id: self.caqh_provider_malpractice_id).last
  end
end

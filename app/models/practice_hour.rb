class PracticeHour < ApplicationRecord
  PRIMARY_KEY_ROW_NAMES = ['ProviderAttestID','ProviderPracticeHoursID','ProviderPracticeID']

  belongs_to :provider_attest
  belongs_to :practice_information

  validates :provider_attest_id, presence: true
  validates :practice_information_id, presence: true

  before_validation :set_provider_attest
  before_validation :set_practice_information
  private

  def set_provider_attest
    self.provider_attest = ProviderAttest.where(caqh_provider_attest_id: self.caqh_provider_attest_id).last
  end

  def set_practice_information
    self.practice_information = PracticeInformation.where(caqh_provider_practice_id: self.caqh_provider_practice_id).last
  end
end

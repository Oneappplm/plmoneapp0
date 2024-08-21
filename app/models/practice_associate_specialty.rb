class PracticeAssociateSpecialty < ApplicationRecord
  self.primary_key = :provider_practice_associate_specialty_id

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: :provider_practice_id
  belongs_to :practice_associate, foreign_key: :provider_practice_associate_id

  validates :provider_attest, presence: true
  validates :practice_information, presence: true
  validates :practice_associate, presence: true

  before_validation :set_provider_attest_id, :set_provider_practice_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.practice_associate.provider_attest_id
  end

  def set_provider_practice_id
    self.provider_practice_id = self.practice_associate.provider_practice_id
  end
end

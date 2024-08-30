class PracticeAssociate < ApplicationRecord
  self.primary_key = :provider_practice_associate_id

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: :provider_practice_id

  validates :provider_attest, presence: true
  validates :practice_information, presence: true

  has_many :practice_associate_other_questions, foreign_key: :provider_practice_associate_id
  has_many :practice_associate_specialties, foreign_key: :provider_practice_associate_id

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.practice_information.provider_attest_id
  end
end

class PracticeOtherQuestion < ApplicationRecord
  self.primary_key = :provider_practice_other_id

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: :provider_practice_id

  has_many :practice_other_tax_ids, foreign_key: :provider_practice_other_id

  validates :provider_attest, presence: true
  validates :practice_information, presence: true

  before_validation :set_provider_attest_id

  private

  def set_provider_attest_id
    self.provider_attest_id = self.practice_information.provider_attest_id
  end
end

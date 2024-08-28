class PracticeAccessibility < ApplicationRecord
  self.primary_key = :provider_practice_accessibility_id

  belongs_to :provider_attest
  belongs_to :practice_information, foreign_key: :provider_practice_id

  validates :provider_attest, presence: true
  validates :practice_information, presence: true

  before_validation :set_provider_attest_id

  def assign_attributes_from_csv_row(row)
    self.assign_attributes({
      "accessibility_flag": row["AccessibilityFlag"],
      "other_accessibility_description": row["OtherAccessibilityDescription"],
      "accessibility_accessibility_description": row["Accessibility_AccessibilityDescription"],
      "provider_practice_id": row["ProviderPracticeID"]
    })
  end

  private

  def set_provider_attest_id
    self.provider_attest_id = self.practice_information.provider_attest_id
  end
end

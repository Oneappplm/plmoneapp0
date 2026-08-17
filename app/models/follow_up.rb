class FollowUp < ApplicationRecord
  belongs_to :enrollment_provider
  belongs_to :user
  belongs_to :approved_by, class_name: "User", optional: true

  enum :resolution_status, { open: 0, awaiting_manager_approval: 1, approved: 2, rejected: 3 }

  validates :notes, presence: true
  validates :next_follow_up_date, presence: true, unless: :resolution_requested?

  private

  def next_follow_up_date_cannot_be_in_the_past
    return if next_follow_up_date.blank?

    if next_follow_up_date < Date.current
      errors.add(
        :next_follow_up_date,
        "cannot be in the past"
      )
    end
  end
end

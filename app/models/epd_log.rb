class EpdLog < ApplicationRecord
  belongs_to :enrollment_providers_detail
  belongs_to :user, foreign_key: :updated_by, optional: true

  def display_summary
    summary = "#{created_at.strftime('%m/%d/%Y')}: Application Status changed to #{status.titleize}"

    if user.present?
      summary += " (updated by #{user.full_name})"
    elsif updated_by.present?
      summary += " (updated by User##{updated_by})"
    end

    summary
  end
end

class EnrollmentProvider::FollowUpReminderService < EnrollmentProvider::BaseService
  def call
    enrollment_provider.details.each do |detail|
      if detail.follow_up_date.present? && detail.saved_change_to_follow_up_date?
        days_remaining = (detail.follow_up_date - Date.today).to_i
        if days_remaining.positive?
          ReminderMailer.follow_up_reminder(@enrollment_provider, detail, days_remaining).deliver_later
        end
      end
    end
  end
end


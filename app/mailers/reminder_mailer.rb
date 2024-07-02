class ReminderMailer < ApplicationMailer
	default from: 'notifications@example.com'

  def follow_up_reminder(enrollment_provider, detail, days_remaining)
    @enrollment_provider = enrollment_provider
    @detail = detail
    @days_remaining = days_remaining
    mail(to: @enrollment_provider.email_address, subject: 'Follow-up Reminder')
  end
end

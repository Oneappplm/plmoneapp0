class ExpirationReminderJob < ApplicationJob
  queue_as :default

  def perform(user, license)
    NotificastionMailer.expiration_reminder(user, license).deliver_now
  end
end

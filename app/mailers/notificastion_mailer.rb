class NotificastionMailer < ApplicationMailer
  def expiration_reminder(user, license)
    @user = user
    @license = license
    mail(to: @user.email, subject: 'License Expiration Reminder')
  end
end

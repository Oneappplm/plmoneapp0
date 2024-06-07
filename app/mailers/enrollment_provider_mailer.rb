class EnrollmentProviderMailer < ApplicationMailer
  default from: 'no-reply@example.com'  # Update with your default sender email

  def status_changed(provider, payer, old_status, new_status, user_email)
    @provider = provider
    @payer = payer
    @old_status = old_status
    @new_status = new_status
    mail(to: ['angela@example.com', user_email], subject: 'Application Status Changed')
  end
end

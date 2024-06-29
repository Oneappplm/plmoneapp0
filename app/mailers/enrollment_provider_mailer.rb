class EnrollmentProviderMailer < ApplicationMailer

  def status_changed(provider, payer, old_status, new_status, user_email)
    @provider = provider
    @payer = payer
    @old_status = old_status
    @new_status = new_status
    mail(to: ['arusso@dentalclaimsupport.com', 'hlevy@dentalclaimsupport.com', user_email], from: from, subject: 'Application Status Changed')
  end
end

class ProviderLicenseMailer < ApplicationMailer
  def renewal_notification(provider_license, days_left)
    @provider_license = provider_license
    @days_left = days_left
    @provider = @provider_license.provider

    mail(
      to: @provider.email,
      subject: "License Renewal Reminder: #{days_left} days left"
    ) do |format|
      format.html { render 'provider_license_mailer/renewal_notification' }
      format.text { render 'provider_license_mailer/renewal_notification' }
    end
  rescue => e
    Rails.logger.error "Error in renewal_notification mailer: #{e.message}"
  end  
end

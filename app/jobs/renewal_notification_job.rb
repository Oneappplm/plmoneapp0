class RenewalNotificationJob < ApplicationJob
  queue_as :default

  def perform(provider_license_id, days_left)
    provider_license = ProviderLicense.find(provider_license_id)
    ProviderLicenseMailer.renewal_notification(provider_license, days_left).deliver_now
  end
end

class OverdueRenewalReminderJob < ApplicationJob
  queue_as :default

  def perform
    ProviderLicense.where('license_state_renewal_date < ?', Date.today).find_each do |provider_license|
      RenewalNotificationJob.perform_later(provider_license.id, "overdue")
    end
  end
end

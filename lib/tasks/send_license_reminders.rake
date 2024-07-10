namespace :send_license_reminders do
  desc "Send license expiration reminders"
  task send: :environment do
    ProviderLicense.all.each do |license|
      user = license.user
      expiration_date = license.expiration_date
      days_left = (expiration_date - Date.today).to_i

      case days_left
      when 30, 20, 10
        ExpirationReminderJob.perform_later(user, license)
      when ..-1
        ExpirationReminderJob.perform_later(user, license)
      end
    end
  end
end

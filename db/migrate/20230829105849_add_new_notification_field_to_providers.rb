class AddNewNotificationFieldToProviders < ActiveRecord::Migration[7.0]
  def change
  add_column :providers, :new_provider_notification, :date
  add_column :providers, :notification_start_date, :date
  add_column :providers, :welcome_letter_sent, :date
  add_column :providers, :notification_enrollment_submit, :date
  add_column :providers, :notification_services, :string
  add_column :providers, :send_welcome_letter, :date
  end
end

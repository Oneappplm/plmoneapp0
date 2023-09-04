class AddNewNotificationFieldsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :new_group_notification, :date
    add_column :enrollment_groups, :noti_group_start_date, :date
    add_column :enrollment_groups, :noti_welcome_letter_sent, :date
    add_column :enrollment_groups, :notification_enrollment_submit_group, :date
    add_column :enrollment_groups, :noti_group_services, :string
    add_column :enrollment_groups, :noti_status, :string
    add_column :enrollment_groups, :noti_work_end_date, :date
  end
end

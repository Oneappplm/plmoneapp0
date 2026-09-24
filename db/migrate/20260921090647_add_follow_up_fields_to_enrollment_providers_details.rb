class AddFollowUpFieldsToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :next_follow_up_date, :date
    add_column :enrollment_providers_details, :follow_up_status, :integer, null: false, default: 0
    add_column :enrollment_providers_details, :assigned_user_id, :bigint
    add_index :enrollment_providers_details, :next_follow_up_date
    add_index :enrollment_providers_details, :follow_up_status
    add_index :enrollment_providers_details, :assigned_user_id
    add_foreign_key :enrollment_providers_details, :users, column: :assigned_user_id
  end
end

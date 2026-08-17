class AddCredentialingFollowUpFieldsToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers, :follow_up_status, :integer, null: false, default: 0
    add_column :enrollment_providers, :next_follow_up_date, :date
    add_index :enrollment_providers, :next_follow_up_date
    add_index :enrollment_providers, :follow_up_status
    add_index :enrollment_providers,
              [:follow_up_status, :next_follow_up_date],
              name: "idx_enrollment_followup_status_date"
  end
end

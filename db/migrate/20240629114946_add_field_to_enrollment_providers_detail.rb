class AddFieldToEnrollmentProvidersDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :follow_up_date, :date
    add_column :enrollment_providers_details, :last_follow_up_date, :date
    add_column :enrollment_providers_details, :completed, :boolean, default: false
  end
end

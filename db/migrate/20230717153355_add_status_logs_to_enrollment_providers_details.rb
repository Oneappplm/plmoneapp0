class AddStatusLogsToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :status_logs, :string, array: true, default: []
  end
end

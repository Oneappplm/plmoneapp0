class AddDatefiledToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :date, :datetime
    add_column :enrollment_providers_details, :attempt_status, :string
    add_column :enrollment_providers_details, :note, :string
    add_column :enrollment_providers_details, :agent_user_id, :integer
  end
end

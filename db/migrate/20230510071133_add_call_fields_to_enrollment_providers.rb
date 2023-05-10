class AddCallFieldsToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers, :user_id, :integer
    add_column :enrollment_providers, :outreach_type, :string
  end
end

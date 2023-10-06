class AddDeniedDataToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :denied_date, :date
  end
end

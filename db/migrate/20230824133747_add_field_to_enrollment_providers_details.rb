class AddFieldToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :processing_date, :string
    add_column :enrollment_providers_details, :terminated_date, :string
  end
end

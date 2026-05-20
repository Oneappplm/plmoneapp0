class AddMissingFieldsToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :payor_email, :string
    add_column :enrollment_providers_details, :payor_phone, :string
    add_column :enrollment_providers_details, :tax_id, :string
    add_column :enrollment_providers_details, :location, :string
  end
end

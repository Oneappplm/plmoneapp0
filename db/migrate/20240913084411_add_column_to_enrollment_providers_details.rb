class AddColumnToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :tax_id, :string
    add_column :enrollment_providers_details, :location, :string
  end
end

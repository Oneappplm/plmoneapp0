class AddcheckboxFieldsToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :non_applicable_for_revalidation, :boolean, default: false
  end
end
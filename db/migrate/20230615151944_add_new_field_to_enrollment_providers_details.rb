class AddNewFieldToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :provider_ptan, :string
    add_column :enrollment_providers_details, :group_ptan, :string
    add_column :enrollment_providers_details, :enrollment_tracking_id, :integer
    add_column :enrollment_providers_details, :enrollment_effective_date, :string
    add_column :enrollment_providers_details, :association_start_date, :string
    add_column :enrollment_providers_details, :business_end_date, :string
    add_column :enrollment_providers_details, :association_end_date, :string
    add_column :enrollment_providers_details, :line_of_business, :string
    add_column :enrollment_providers_details, :revalidation_status, :string
  end
end
 
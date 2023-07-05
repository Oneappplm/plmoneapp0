class AddQualifactsFieldsToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def up
    add_column :enrollment_providers_details, :cpt_code, :string
    add_column :enrollment_providers_details, :descriptor, :string
    add_column :enrollment_providers_details, :provider_id, :string
    add_column :enrollment_providers_details, :group_id, :string
  end

  def down
    remove_column :enrollment_providers_details, :cpt_code, :string
    remove_column :enrollment_providers_details, :descriptor, :string
    remove_column :enrollment_providers_details, :provider_id, :string
    remove_column :enrollment_providers_details, :group_id, :string
  end
end

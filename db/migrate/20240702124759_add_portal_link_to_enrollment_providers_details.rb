class AddPortalLinkToEnrollmentProvidersDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers_details, :portal_link, :string, if_not_exists: true
  end
end

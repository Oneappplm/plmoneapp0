class AddMasterListsToProviderPersonalInformationAppTracking < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_information_app_trackings, :master_issues, :string, array: true, default: [] if !column_exists?(:provider_personal_information_app_trackings, :master_issues)
    add_column :provider_personal_information_app_trackings, :master_reviews, :string, array: true, default: [] if !column_exists?(:provider_personal_information_app_trackings, :master_reviews)
  end
end

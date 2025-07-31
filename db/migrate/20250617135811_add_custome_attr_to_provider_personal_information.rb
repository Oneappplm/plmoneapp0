class AddCustomeAttrToProviderPersonalInformation < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:provider_personal_informations, :progress_status)
      add_column :provider_personal_informations, :progress_status, :string
    end

    add_column :provider_personal_informations, :committee_date, :datetime
    add_column :provider_personal_informations, :review_details, :string
    add_column :provider_personal_informations, :cred_cycle, :string
  end
end

class AddFieldForPracticeInformation < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_information_credentialing_contacts, :caqh_provider_cred_contact_id, :integer
  end
end

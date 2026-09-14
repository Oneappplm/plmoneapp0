class AddFieldsToProviderPersonalInformationCredentialingContacts < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_personal_information_credentialing_contacts do |t|
      t.string :suffix_of_credentialing_contact
      t.string :fax_number
      t.string :email_address
      t.string :suit_or_apt
      t.string :additional_address
      t.string :state_or_province
      t.string :zipcode
    end
  end
end

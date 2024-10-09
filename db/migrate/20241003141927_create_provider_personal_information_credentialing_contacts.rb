class CreateProviderPersonalInformationCredentialingContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_credentialing_contacts do |t|
      t.string :contact_method
      t.string :firstname
      t.string :middlename
      t.string :lastname
      t.string :title
      t.string :suffix
      t.string :phone_number
      t.string :fax
      t.string :email
      t.string :address
      t.string :suite
      t.string :address2
      t.string :city
      t.string :county
      t.string :state
      t.string :zip
      t.string :country
      t.references :provider_personal_information, index: false

      t.timestamps
    end

    add_index  :provider_personal_information_credentialing_contacts, :provider_personal_information_id, :name => 'ppicc_ppi_id'
  end
end

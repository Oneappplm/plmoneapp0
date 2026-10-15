class CreateProviderPersonalInformationPeerRefs < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_peer_refs do |t|
      t.references :provider_attest, index: { name: "idx_peer_refs_attest_id" }
      t.integer :caqh_provider_attest_id
      t.string :title
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :practitioner_type
      t.string :specialty
      t.boolean :is_board_certified
      t.string :contact_method
      t.string :address
      t.string :suite_dept_mail_stop
      t.string :facility_name
      t.string :city
      t.string :country
      t.string :state
      t.string :county
      t.string :zip_code
      t.string :phone_number
      t.string :fax_number
      t.string :email_address
      t.text :comments
      t.boolean :show_on_tickler, default: false

      t.timestamps
    end
  end
end

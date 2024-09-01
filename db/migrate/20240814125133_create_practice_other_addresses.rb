class CreatePracticeOtherAddresses < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_other_addresses, primary_key: [:provider_attest_id,:provider_practice_address_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_address_id
      t.references    :provider_attest
      t.string        :address
      t.string        :address2
      t.string        :city
      t.string        :county
      t.string        :state
      t.string        :postal_code
      t.string        :province
      t.string        :phone_number
      t.string        :fax_number
      t.string        :emergency_phone_number
      t.string        :answering_service_phone_number
      t.string        :email_address
      t.string        :check_payable_to
      t.string        :company_name
      t.string        :attention
      t.text          :address_type_address_type_description
      t.text          :country_country_name
      t.integer       :provider_practice_id

      t.timestamps
    end

    add_index  :practice_other_addresses, :provider_practice_id, :name => 'poa_pp_id'
  end

  def self.down
    drop_table :practice_other_addresses
  end
end

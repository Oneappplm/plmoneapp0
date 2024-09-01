class CreateProviderNonPracticeAddresses < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_non_practice_addresses, primary_key: [:provider_attest_id,:provider_address_id] do |t|
      t.integer        :provider_address_id
      t.references     :provider_attest
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :postal_code
      t.string         :years_at_this_address
      t.string         :province
      t.string         :phone_number
      t.string         :fax_number
      t.string         :email_address
      t.string         :county
      t.boolean        :unlisted_flag
      t.text           :address_type_address_type_description
      t.string         :country_country_name

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_non_practice_addresses
  end
end

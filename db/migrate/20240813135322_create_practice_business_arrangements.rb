class CreatePracticeBusinessArrangements < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_business_arrangements do |t|
      t.integer     :caqh_provider_practice_business_arrangement_id
      t.references  :provider_attest
      t.integer     :caqh_provider_attest_id
      t.string      :business_arrangement_name
      t.string      :business_arrangement_type
      t.string      :tax_id
      t.string      :address
      t.string      :address2
      t.string      :city
      t.string      :state
      t.string      :postal_code
      t.string      :phone_number
      t.string      :country_country_name
      t.references  :practice_information
      t.integer     :caqh_provider_practice_id
      t.timestamps
    end
  end

  def self.down
    drop_table :practice_business_arrangements
  end
end

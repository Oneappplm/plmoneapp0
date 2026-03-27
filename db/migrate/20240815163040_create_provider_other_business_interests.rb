class CreateProviderOtherBusinessInterests < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_other_business_interests do |t|
      t.integer        :caqh_provider_other_business_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :organization_name
      t.string         :organization_type
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :zip
      t.string         :ext_zip
      t.string         :phone_number
      t.string         :tax_id
      t.string         :percent_owned
      t.boolean        :investment_type

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_other_business_interests
  end
end

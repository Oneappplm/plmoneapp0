class CreatePracticeBusinessArrangements < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_business_arrangements, primary_key: [:provider_attest_id,:provider_practice_business_arrangement_id,:provider_practice_id] do |t|
      t.integer     :provider_practice_business_arrangement_id
      t.references  :provider_attest
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
      t.integer    :provider_practice_id
      t.timestamps
    end

    add_index  :practice_business_arrangements, :provider_practice_id, :name => 'pba_pp_id'
  end

  def self.down
    drop_table :practice_business_arrangements
  end
end

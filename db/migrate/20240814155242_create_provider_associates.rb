class CreateProviderAssociates < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_associates, primary_key: [:provider_attest_id,:provider_associate_id] do |t|
      t.integer      :provider_associate_id
      t.references   :provider_attest
      t.string       :associate_first_name
      t.string       :associate_last_name
      t.string       :associate_middle_initial
      t.string       :associate_name
      t.string       :address
      t.string       :address2
      t.string       :city
      t.string       :state
      t.string       :postal_code
      t.string       :province
      t.string       :phone_number
      t.string       :phone_extension
      t.string       :fax_number
      t.string       :email_address
      t.string       :title
      t.string       :country_country_name
      t.string       :specialty_specialty_name
      t.string       :degree_degree_abbreviation
      t.text         :associate_type_associate_type_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_associates
  end
end

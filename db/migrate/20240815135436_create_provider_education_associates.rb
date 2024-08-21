class CreateProviderEducationAssociates < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_education_associates, id: false do |t|
      t.primary_key    :provider_education_associate_id
      t.references     :provider_attest
      t.references     :provider_education
      t.string         :associate_first_name
      t.string         :associate_last_name
      t.string         :associate_middle_initial
      t.string         :title
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :province
      t.string         :postal_code
      t.string         :phone_number
      t.string         :phone_extension
      t.string         :fax_number
      t.string         :email_address
      t.string         :country_country_name
      t.text           :associate_type_associate_type_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_education_associates
  end
end

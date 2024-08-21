class CreateProviderReferences < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_references, id: false do |t|
      t.primary_key    :provider_reference_id
      t.references     :provider_attest
      t.string         :first_name
      t.string         :last_name
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :province
      t.string         :postal_code
      t.string         :phone_number
      t.datetime       :start_date
      t.datetime       :end_date
      t.string         :title
      t.string         :fax_number
      t.string         :relationship
      t.string         :years_known
      t.string         :middle_name
      t.string         :employer_name
      t.string         :email_address
      t.string         :cell_phone_number
      t.string         :phone_extension
      t.string         :phone_number2
      t.string         :phone_number2_extension
      t.string         :department
      t.string         :country_country_name
      t.string         :specialty_specialty_name
      t.string         :reference_type_provider_type_abbreviation
      t.string         :degree_degree_abbreviation

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_references
  end
end

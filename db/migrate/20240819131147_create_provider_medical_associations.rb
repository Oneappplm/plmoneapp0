class CreateProviderMedicalAssociations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_medical_associations, primary_key: [:provider_attest_id,:provider_medical_association_id] do |t|
      t.integer        :provider_medical_association_id
      t.references     :provider_attest
      t.string         :association_name
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :county
      t.string         :state
      t.string         :postal_code
      t.string         :ext_zip
      t.string         :phone_number
      t.string         :fax_number
      t.string         :answering_service_phone_number
      t.string         :association_type
      t.datetime       :start_date
      t.datetime       :end_date
      t.text           :explanation
      t.text           :geographic_range_geographic_range_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_medical_associations
  end
end

class CreateProviderHospitalAssociates < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_hospital_associates do |t|
      t.integer        :caqh_provider_hospital_associate_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :associate_first_name
      t.string         :associate_last_name
      t.string         :associate_middle_initial
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :zip
      t.string         :county
      t.string         :postal_code
      t.string         :phone_number
      t.string         :fax_number
      t.string         :email_address
      t.text           :associate_type_associate_type_description
      t.references     :provider_hospital_privilege, index: false
      t.integer        :caqh_provider_hospital_id
      t.timestamps
    end
  end

  def self.down
    drop_table :provider_hospital_associates
  end
end

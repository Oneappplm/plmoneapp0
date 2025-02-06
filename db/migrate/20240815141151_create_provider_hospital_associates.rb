class CreateProviderHospitalAssociates < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_hospital_associates, primary_key: [:provider_attest_id,:provider_hospital_associate_id,:provider_hospital_id] do |t|
      t.integer        :provider_hospital_associate_id
      t.references     :provider_attest
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
      t.integer        :provider_hospital_id
      t.timestamps
    end

    add_index  :provider_hospital_associates, :provider_hospital_id, :name => 'pha_ph_id'
  end

  def self.down
    drop_table :provider_hospital_associates
  end
end

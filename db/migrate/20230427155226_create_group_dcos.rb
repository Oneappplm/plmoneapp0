class CreateGroupDcos < ActiveRecord::Migration[7.0]
  def change
    create_table :group_dcos do |t|
      t.references :enrollment_group, null: false, foreign_key: true
      t.string :client
      t.string :dco_name
      t.string :dco_address
      t.string :dco_city
      t.string :state
      t.string :dco_zipcode
      t.string :country
      t.string :service_location_phone_number
      t.string :service_location_fax_number
      t.string :panel_status_to_new_patients
      t.string :panel_age_limit
      t.string :include_in_directory
      t.string :dco_provider_name
      t.string :dco_provider_email
      t.string :dco_provider_phone_number
      t.string :dco_provider_fax_number
      t.string :dco_provider_position

      t.timestamps
    end
  end
end

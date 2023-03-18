class CreateClients < ActiveRecord::Migration[7.0]
  def up
    create_table :clients do |t|
      t.string :full_name
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :provider_name
      t.date :birth_date
      t.string :state
      t.string :state_abbr
      t.string :street_address
      t.string :city
      t.string :zipcode
      t.date :attested_date
      t.string :npi
      t.string :ssn
      t.string :provider_type
      t.string :specialty
      t.string :tin
      t.string :entity
      t.string :cred_status
      t.string :cred_cycle
      t.string :vrc_status
      t.string :psv_flat
      t.string :medv_id

      t.timestamps
    end
  end

  def down
    drop_table :clients
  end
end

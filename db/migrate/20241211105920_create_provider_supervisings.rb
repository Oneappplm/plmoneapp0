class CreateProviderSupervisings < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_supervisings do |t|
      t.string :name_of_supervising
      t.integer :license_state
      t.string :license_type
      t.string :license_number
      t.string :facility
      t.string :address
      t.string :mail_stop
      t.string :address2
      t.string :city
      t.string :state
      t.string :country
      t.string :zipcode
      t.string :phone_number
      t.string :fax_number
      t.string :email_address
      t.references :provider_licensure

      t.timestamps
    end
  end
end

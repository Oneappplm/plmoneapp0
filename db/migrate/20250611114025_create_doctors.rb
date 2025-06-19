class CreateDoctors < ActiveRecord::Migration[7.0]
  def change
    create_table :doctors do |t|
      t.string :first_name
      t.string :last_name
      t.string :specialty
      t.string :license_number
      t.string :email
      t.string :phone
      t.string :password_digest
      t.string :clinic_name
      t.string :clinic_address
      t.string :location
      t.boolean :email_verified
      t.boolean :phone_verified
      t.boolean :license_verified

      t.timestamps
    end
  end
end

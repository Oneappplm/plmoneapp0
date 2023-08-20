class CreateGroupEngageProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :group_engage_providers do |t|
      t.integer :practice_location_id
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.datetime :date_of_birth
      t.string :email_address
      t.string :ssn

      t.timestamps
    end
  end
end

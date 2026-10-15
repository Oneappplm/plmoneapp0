class CreateAlliedHealthPractitioners < ActiveRecord::Migration[7.0]
  def change
    create_table :allied_health_practitioners do |t|
      t.string :first_name
      t.string :last_name
      t.string :suffix
      t.string :type_of_practitioner
      t.string :mail_stop
      t.string :address
      t.string :address2
      t.string :city
      t.string :county
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :state_license_number
      t.boolean :listed_as_pcp, default: false
      t.references :practice_information

      t.timestamps
    end
  end
end

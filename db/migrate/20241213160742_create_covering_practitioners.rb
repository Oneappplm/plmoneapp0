class CreateCoveringPractitioners < ActiveRecord::Migration[7.0]
  def change
    create_table :covering_practitioners do |t|
      t.string :practitioner_name
      t.string :facility
      t.string :address
      t.string :mail_stop
      t.string :address2
      t.string :city
      t.string :country
      t.string :state
      t.string :zipcode
      t.string :phone_number
      t.string :fax_number
      t.string :email_address
      t.references :practice_information

      t.timestamps
    end
  end
end

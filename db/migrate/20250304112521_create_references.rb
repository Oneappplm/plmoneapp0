class CreateReferences < ActiveRecord::Migration[7.0]
  def change
    create_table :references do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :suffix
      t.string :degree, null: false
      t.string :specialty
      t.string :contact_method, null: false
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zipcode, null: false
      t.string :telephone_number, null: false
      t.string :ext
      t.string :fax, null: false
      t.boolean :does_not_have_fax, default: false
      t.string :mobile_number
      t.string :email_address, null: false
      t.date :association_start_date, null: false
      t.date :association_end_date
      t.boolean :association_until_present, default: false
      t.string :relationship
      t.timestamps
    end
  end
end

class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :address
      t.string :suite
      t.string :address2
      t.string :city
      t.string :county
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :contact_method
      t.string :phone
      t.string :fax
      t.string :email
      t.timestamps
    end
  end
end

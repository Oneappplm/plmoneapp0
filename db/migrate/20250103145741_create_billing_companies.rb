class CreateBillingCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :billing_companies do |t|
      t.string :billing_company_name
      t.string :address
      t.string :suite
      t.string :additional_address
      t.string :city
      t.string :county
      t.string :state
      t.string :zip
      t.string :country
      t.string :phone_number
      t.string :contact
      t.string :fax_number
      t.string :email
      t.string :name_affiliated_with_tax_id
      t.string :federal_tax_id
      t.string :check_payable_to
      t.boolean :bills_electronically
      t.text :comments

      t.timestamps
    end
  end  
end

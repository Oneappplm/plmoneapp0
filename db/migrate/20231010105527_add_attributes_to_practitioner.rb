class AddAttributesToPractitioner < ActiveRecord::Migration[7.0]
  def change
    add_column :practitioners, :first_name, :string
    add_column :practitioners, :middle_name, :string
    add_column :practitioners, :last_name, :string
    add_column :practitioners, :suffix, :string
    add_column :practitioners, :gender, :string
    add_column :practitioners, :date_of_birth, :date
    add_column :practitioners, :social_security_number, :string
    add_column :practitioners, :contact_method, :string
    add_column :practitioners, :phone_number, :string
    add_column :practitioners, :fax_number, :string
    add_column :practitioners, :email_address, :string
    add_column :practitioners, :address, :string
    add_column :practitioners, :suit_or_apt, :string
    add_column :practitioners, :additional_address, :string
    add_column :practitioners, :city, :string
    add_column :practitioners, :country, :string
    add_column :practitioners, :state_or_province, :string
    add_column :practitioners, :zipcode, :string
    add_column :practitioners, :practitioner_type, :string
    add_column :practitioners, :credentials_committee_date, :date
    add_column :practitioners, :client_batch_name, :string
    add_column :practitioners, :client_batch_id, :string
    add_column :practitioners, :market, :string
    add_column :practitioners, :status, :string
    add_column :practitioners, :application_method, :string
    add_column :practitioners, :availability, :string
    add_column :practitioners, :county, :string

  end
end

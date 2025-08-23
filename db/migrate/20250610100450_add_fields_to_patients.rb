class AddFieldsToPatients < ActiveRecord::Migration[7.0]
  def change
    add_column :patients, :gender, :string
    add_column :patients, :email_address, :string
    add_column :patients, :phone_number, :string
    add_column :patients, :current_medications, :text
    add_column :patients, :insurance_information, :string
    add_column :patients, :allergies, :text
    add_column :patients, :address, :string
    add_column :patients, :next_appointment, :date
    add_column :patients, :last_visit_date, :date
    add_column :patients, :active, :boolean
  end
end

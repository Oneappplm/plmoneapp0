class AddColumnsToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers, :first_name, :string
    add_column :enrollment_providers, :middle_name, :string
    add_column :enrollment_providers, :last_name, :string
    add_column :enrollment_providers, :suffix, :string
    add_column :enrollment_providers, :telephone_number, :string
    add_column :enrollment_providers, :email_address, :string
  end
end

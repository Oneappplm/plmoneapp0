class AddNewCheckboxToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :billing_address_autofill, :string
    add_column :enrollment_groups, :remittance_address_autofill, :string
  end
end

class AddFieldsToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :remmitance_contact_name, :string
    add_column :enrollment_groups, :remmitance_contact_number, :string
    add_column :enrollment_groups, :remmitance_contact_email, :string

    add_column :enrollment_groups, :billing_contact_name, :string
    add_column :enrollment_groups, :billing_contact_number, :string
    add_column :enrollment_groups, :billing_contact_email, :string

    add_column :enrollment_groups, :qualifacts_contract_effective_date, :datetime

  end
end

class AddEmailAddressToEnrollmentGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups_details, :email_address, :string, if_not_exists: true
  end
end

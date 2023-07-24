class AddEmailToEnrollmentGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups_details, :email_address, :string
  end
end

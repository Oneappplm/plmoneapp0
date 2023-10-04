class AddMissingFieldsToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :payer_state, :string, if_not_exists: true
    add_column :enroll_groups_details, :payor_submission_type, :string, if_not_exists: true
    add_column :enroll_groups_details, :payor_link, :string, if_not_exists: true
  end
end

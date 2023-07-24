class AddFieldsToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :payor_submission_type, :string
    add_column :enroll_groups_details, :payor_link, :string
  end
end

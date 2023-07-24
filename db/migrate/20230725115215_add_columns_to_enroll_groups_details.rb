class AddColumnsToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :portal_username, :string
    add_column :enroll_groups_details, :portal_password, :string
    add_column :enroll_groups_details, :upload_payor_file, :string
  end
end

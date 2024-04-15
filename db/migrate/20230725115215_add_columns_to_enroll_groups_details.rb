class AddColumnsToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :portal_username, :string, if_not_exists: true
    add_column :enroll_groups_details, :portal_password, :string, if_not_exists: true
    add_column :enroll_groups_details, :upload_payor_file, :string, if_not_exists: true
  end
end

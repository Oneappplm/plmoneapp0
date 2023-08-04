class AddColumnUploadPayorFileToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :upload_payor_file, :json
  end
end

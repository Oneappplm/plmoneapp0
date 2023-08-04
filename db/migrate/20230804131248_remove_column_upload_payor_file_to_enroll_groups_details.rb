class RemoveColumnUploadPayorFileToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :enroll_groups_details, :upload_payor_file, :string
  end
end

class RenamePayorPasswordToPassword < ActiveRecord::Migration[7.0]
  def up
    rename_column :enroll_groups_details, :payor_password, :password
  end

  def down
    rename_column :enroll_groups_details, :password, :payor_password
  end
end

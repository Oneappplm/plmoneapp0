class AddPasswordDigestToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def up
    add_column :enroll_groups_details, :password_digest, :string
  end

  def down
    remove_column :enroll_groups_details, :password_digest, :string
  end
end

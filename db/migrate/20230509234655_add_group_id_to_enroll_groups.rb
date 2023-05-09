class AddGroupIdToEnrollGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups, :group_id, :integer
  end
end

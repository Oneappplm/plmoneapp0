class AddDcoToEnrollGroups < ActiveRecord::Migration[7.0]
  def up
    add_column :enroll_groups, :dco, :integer
  end

  def down
    remove_column :enroll_groups, :dco, :integer
  end
end

class AddEnrollmentGroupIdToProviders < ActiveRecord::Migration[7.0]
  def up
    add_column :providers, :enrollment_group_id, :integer
  end

  def down
    remove_column :providers, :enrollment_group_id, :integer
  end
end

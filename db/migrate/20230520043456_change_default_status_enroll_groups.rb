class ChangeDefaultStatusEnrollGroups < ActiveRecord::Migration[7.0]
  def up
    change_column_default :enroll_groups, :status, 'pending'
  end

  def down
    change_column_default :enroll_groups, :status, nil
  end
end

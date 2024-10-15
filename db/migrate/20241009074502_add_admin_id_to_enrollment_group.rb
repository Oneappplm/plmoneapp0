class AddAdminIdToEnrollmentGroup < ActiveRecord::Migration[7.0]
  def change
    add_reference :enrollment_groups, :admin, foreign_key: { to_table: :users }, type: :integer, null: true
  end
end

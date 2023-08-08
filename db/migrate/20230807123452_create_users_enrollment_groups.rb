class CreateUsersEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :users_enrollment_groups do |t|
      t.references :user
      t.references :enrollment_group
      t.timestamps
    end
  end
end

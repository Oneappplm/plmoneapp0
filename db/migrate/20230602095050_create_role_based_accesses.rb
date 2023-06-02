class CreateRoleBasedAccesses < ActiveRecord::Migration[7.0]
  def change
    create_table :role_based_accesses do |t|
      t.string :role
      t.string :page
      t.boolean :can_create
      t.boolean :can_read
      t.boolean :can_update
      t.boolean :can_delete

      t.timestamps
    end
  end
end

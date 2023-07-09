class CreateGroupDcoContacts < ActiveRecord::Migration[7.0]
  def up
    create_table :group_dco_contacts do |t|
      t.references :group_dco
      t.string :department
      t.string :name
      t.string :role
      t.string :phone
      t.string :email

      t.timestamps
    end
  end

  def down
    drop_table :group_dco_contacts
  end
end

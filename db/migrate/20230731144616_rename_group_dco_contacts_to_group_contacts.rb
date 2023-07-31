class RenameGroupDcoContactsToGroupContacts < ActiveRecord::Migration[7.0]
  def change
    rename_table :group_dco_contacts, :group_contacts
  end
end

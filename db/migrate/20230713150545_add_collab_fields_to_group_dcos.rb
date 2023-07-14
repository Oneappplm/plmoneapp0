class AddCollabFieldsToGroupDcos < ActiveRecord::Migration[7.0]
  def up
    add_column :group_dcos, :collab_name, :string
    add_column :group_dcos, :collab_npi, :string
  end

  def down
    remove_column :group_dcos, :collab_name, :string
    remove_column :group_dcos, :collab_npi, :string
  end
end

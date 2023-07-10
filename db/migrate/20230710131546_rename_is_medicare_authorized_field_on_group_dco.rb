class RenameIsMedicareAuthorizedFieldOnGroupDco < ActiveRecord::Migration[7.0]
  def up
    rename_column :group_dcos, :is_medicare_authorized, :medicare_authorized_official
  end

  def down
    rename_column :group_dcos, :medicare_authorized_official, :is_medicare_authorized
  end
end

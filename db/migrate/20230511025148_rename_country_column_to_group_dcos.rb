class RenameCountryColumnToGroupDcos < ActiveRecord::Migration[7.0]
  def change
    rename_column :group_dcos, :country, :county
  end
end

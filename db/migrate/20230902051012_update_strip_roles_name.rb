class UpdateStripRolesName < ActiveRecord::Migration[7.0]
  def change
    Role.update_name_remove_whitespace
  end
end

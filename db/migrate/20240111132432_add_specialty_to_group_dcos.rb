class AddSpecialtyToGroupDcos < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :specialty, :string
  end
end

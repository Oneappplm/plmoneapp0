class AddEffectiveDateToGroupDcos < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :effective_date, :date
  end
end

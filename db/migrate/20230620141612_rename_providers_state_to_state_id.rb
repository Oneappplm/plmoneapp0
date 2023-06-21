class RenameProvidersStateToStateId < ActiveRecord::Migration[7.0]
  def up
    rename_column :providers, :state, :state_id
  end

  def down
    rename_column :providers, :state_id, :state
  end
end

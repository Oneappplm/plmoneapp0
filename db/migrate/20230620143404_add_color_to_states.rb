class AddColorToStates < ActiveRecord::Migration[7.0]
  def up
    add_column :states, :color, :string
  end

  def down
    remove_column :states, :color, :string
  end
end

class CreateBoardNames < ActiveRecord::Migration[7.0]
  def change
    create_table :board_names do |t|
      t.string :name
      t.timestamps
    end
  end
end

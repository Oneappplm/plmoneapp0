class CreateGroupDcoNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :group_dco_notes do |t|
      t.references :group_dco
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end

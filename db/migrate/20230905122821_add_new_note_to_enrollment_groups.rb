class AddNewNoteToEnrollmentGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :group_note, :string
  end
end

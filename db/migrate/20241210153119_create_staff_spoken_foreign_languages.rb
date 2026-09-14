class CreateStaffSpokenForeignLanguages < ActiveRecord::Migration[7.0]
  def change
    create_table :staff_spoken_foreign_languages do |t|
      t.string :language
      t.boolean :is_spoken, default: false
      t.boolean :is_read, default: false
      t.boolean :is_write, default: false
      t.boolean :is_interpreter_available, default: false
      t.string :specific_language
      t.references :practice_information

      t.timestamps
    end
  end
end

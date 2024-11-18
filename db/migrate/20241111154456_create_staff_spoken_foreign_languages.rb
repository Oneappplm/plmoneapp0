class CreateStaffSpokenForeignLanguages < ActiveRecord::Migration[7.0]
  def change
    create_table :staff_spoken_foreign_languages do |t|
      t.string :language
      t.boolean :is_spoken
      t.boolean :is_read
      t.boolean :is_write
      t.boolean :is_interpreter_available
      t.string :specific_language

      t.references :practice_information
      t.timestamps
    end
  end
end

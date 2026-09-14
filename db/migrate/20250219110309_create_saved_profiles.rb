class CreateSavedProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_profiles do |t|
      t.string :file_path
      t.string :file_type
      t.references :pdf_generation_queue, null: false, foreign_key: true

      t.timestamps
    end
  end
end

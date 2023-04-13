class CreateDisclosureQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :disclosure_questions do |t|
      t.references :disclosure_category
      t.text :question
      t.string :slug
      t.string :note
      t.string :alert_type

      t.timestamps
    end
  end
end

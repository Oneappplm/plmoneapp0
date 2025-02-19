class CreateFaqs < ActiveRecord::Migration[7.0]
  def change
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.boolean :visible

      t.timestamps
    end
  end
end

class CreateEnrollmentProviderDetailQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :epd_questions do |t|
      t.references :enrollment_providers_detail, null: false, foreign_key: true
      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end

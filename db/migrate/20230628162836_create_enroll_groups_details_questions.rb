class CreateEnrollGroupsDetailsQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :enroll_groups_details_questions do |t|
      t.integer :enroll_groups_detail_id
      t.string :secret_question
      t.string :answer

      t.timestamps
    end
  end
end

class CreateProviderOtherQuestions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_other_questions, primary_key: [:provider_attest_id,:provider_other_id] do |t|
      t.integer        :provider_other_id
      t.references     :provider_attest
      t.boolean        :provider_answer_flag
      t.text           :provider_answer_text
      t.datetime       :provider_answer_date
      t.text           :other_question_other_question_summary

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_other_questions
  end
end

class CreatePracticeOtherQuestions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_other_questions, primary_key: [:provider_attest_id,:provider_practice_other_id,:provider_practice_id] do |t|
      t.integer       :provider_practice_other_id
      t.references    :provider_attest
      t.boolean       :para_professional_flag
      t.boolean       :para_professional_supervision_flag
      t.boolean       :para_professional_billing_flag
      t.boolean       :provider_practice_answer_flag
      t.string        :provider_practice_answer_text
      t.datetime      :provider_practice_answer_date
      t.text          :other_question_other_question_summary
      t.integer       :provider_practice_id
      t.timestamps
    end

    add_index  :practice_other_questions, :provider_practice_id, :name => 'poq_pp_id'
  end

  def self.down
    drop_table :practice_other_questions
  end
end

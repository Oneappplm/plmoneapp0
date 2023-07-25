class CreateProvidersPayerLoginsQuestions < ActiveRecord::Migration[7.0]
  def up
    create_table :providers_payer_logins_questions do |t|
      t.integer :providers_payer_login_id
      t.string :question
      t.string :answer
      t.timestamps
    end
  end

  def down
    drop_table :providers_payer_logins_questions
  end
end

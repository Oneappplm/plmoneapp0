class AddSecurityQuestionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :security_question, :string, null: true
    add_column :users, :security_answer, :string, null: true
  end
end

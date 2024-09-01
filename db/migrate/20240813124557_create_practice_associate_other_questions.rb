class CreatePracticeAssociateOtherQuestions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associate_other_questions, primary_key: [:provider_attest_id, :provider_practice_associate_other_id, :provider_practice_associate_id, :provider_practice_id] do |t|
      t.integer :provider_practice_associate_other_id
      t.references  :provider_attest
      t.string      :coverage_availability
      t.integer     :provider_practice_id
      t.integer     :provider_practice_associate_id
      t.timestamps
    end

    add_index  :practice_associate_other_questions, :provider_practice_id, :name => 'paoq_pp_id'
    add_index  :practice_associate_other_questions, :provider_practice_associate_id, :name => 'paoq_ppa_id'
  end

  def self.down
    drop_table :practice_associate_other_questions
  end
end

class CreatePracticeAssociateOtherQuestions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associate_other_questions, id: false do |t|
      t.primary_key :provider_practice_associate_other_id
      t.references  :provider_attest
      t.string      :coverage_availability

      t.timestamps
    end

    add_column :practice_associate_other_questions, :provider_practice_id, :integer
    add_column :practice_associate_other_questions, :provider_practice_associate_id, :integer

    add_index  :practice_associate_other_questions, :provider_practice_id, :name => 'paoq_pp_id'
    add_index  :practice_associate_other_questions, :provider_practice_associate_id, :name => 'paoq_ppa_id'
  end

  def self.down
    drop_table :practice_associate_other_questions
  end
end

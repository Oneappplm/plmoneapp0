class CreatePracticeAssociateOtherQuestions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associate_other_questions do |t|
      t.integer     :caqh_provider_practice_associate_other_id
      t.references  :provider_attest
      t.integer     :caqh_provider_attest_id
      t.string      :coverage_availability
      t.references  :practice_information, index: false
      t.references  :practice_associate, index: false
      t.integer     :caqh_provider_practice_id
      t.integer     :caqh_provider_practice_associate_id
      t.timestamps
    end

    add_index  :practice_associate_other_questions, :practice_information_id, :name => 'paoq_pp_id'
    add_index  :practice_associate_other_questions, :practice_associate_id, :name => 'paoq_ppa_id'
  end

  def self.down
    drop_table :practice_associate_other_questions
  end
end

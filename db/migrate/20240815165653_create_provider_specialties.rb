class CreateProviderSpecialties < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_specialties do |t|
      t.integer         :caqh_provider_specialty_id
      t.references      :provider_attest
      t.integer         :caqh_provider_attest_id
      t.string          :board_certified_flag
      t.datetime        :certification_date
      t.datetime        :recertification_date
      t.datetime        :expiration_date
      t.datetime        :future_board_exam_date
      t.boolean         :hmo_flag
      t.boolean         :ppo_flag
      t.boolean         :pos_flag
      t.boolean         :board_certification_expires_flag
      t.boolean         :recertified_flag
      t.datetime        :status_expiration_date
      t.boolean         :results_pending_flag
      t.boolean         :list_in_directory_flag
      t.string          :specialty_board_name
      t.boolean         :failed_board_exam_flag
      t.string          :failed_board_exam_board_name
      t.datetime        :failed_board_exam_date
      t.boolean         :apply_certification_flag
      t.boolean         :intend_apply_certification_flag
      t.datetime        :intend_apply_certification_date
      t.boolean         :exam_accepted_flag
      t.text            :no_certification_explanation
      t.datetime        :admissibility_expiration_date
      t.boolean         :partial_exam_flag
      t.string          :exam_name
      t.boolean         :intending_board_flag
      t.boolean         :not_intending_board_flag
      t.datetime        :exam_taken_date
      t.boolean         :current_certification_flag
      t.datetime        :initial_certification_date
      t.text            :failed_board_exam_explanation
      t.datetime        :future_board_exam_date_oral
      t.datetime        :future_board_exam_date_written
      t.string          :certification_number
      t.string          :specialty_percent
      t.datetime        :status_date
      t.boolean         :abms_flag
      t.string          :results_pending_specialty_board_name
      t.string          :failed_board_exam_attempts
      t.boolean         :not_eligible_board_flag
      t.datetime        :apply_certification_date
      t.string          :specialty_board_address
      t.string          :specialty_board_address2
      t.string          :specialty_board_city
      t.string          :specialty_board_state
      t.string          :specialty_board_postal_code
      t.text            :non_certified_status_non_certified_status_description
      t.text            :specialty_classification_specialty_classification_description
      t.text            :specialty_status_specialty_status_description
      t.string          :sub_specialty_specialty_name
      t.string          :specialty_specialty_name
      t.text            :specialty_type_specialty_type_description
      t.string          :special_experience_skillsand_training_section

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_specialties
  end
end

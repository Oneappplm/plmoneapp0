class CreateProviderSourceSpecialities < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_source_specialities do |t|
      t.references :provider_source, null: false, foreign_key: true

      t.integer :ranking
      t.string :speciality
      t.boolean :board_certified
      t.string :certifying_board
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :board_certificate_number
      t.string :telephone
      t.string :ext
      t.string :fax_number
      t.date :initial_certification_date
      t.date :expiration_certification_date
      t.date :recertification_date
      t.boolean :eligible_certified
      t.date :admissibility_expiration_date

      t.boolean :board_exam_results_pending
      # Fields for when the exam is pending
      t.string :pending_certifying_board
      t.string :pending_address_line_1
      t.string :pending_address_line_2
      t.string :pending_city
      t.string :pending_state
      t.string :pending_zipcode
      t.string :pending_telephone
      t.string :pending_ext
      t.string :pending_fax_number
      t.date :pending_board_exam_date
      t.date :board_exam_date
      t.boolean :applied_for_certification_exam
      t.boolean :intend_applied_for_certification_exam
      t.date :intend_date_apply
      t.text :specialties_no_board_exam_reason
      t.boolean :accepted_for_certification_exam
      t.timestamps
    end
  end
end


class CreateEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_providers do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :due_date
      t.string :enrollment_payer
      t.datetime :revalidation_date
      t.string :enrollment_type
      t.datetime :state_license_submitted
      t.string :state_license_file
      t.datetime :dea_submitted
      t.string :dea_file
      t.datetime :irs_letter_submitted
      t.string :irs_letter_file
      t.datetime :w9_submitted
      t.string :w9_file
      t.datetime :voided_check_submitted
      t.string :voided_check_file
      t.datetime :curriculum_vitae_submitted
      t.string :curriculum_vitae_file
      t.datetime :cms_460_submitted
      t.string :cms_460_file
      t.datetime :eft_submitted
      t.string :eft_file
      t.datetime :cert_insurance_submitted
      t.string :cert_insurance_file
      t.datetime :driver_license_submitted
      t.string :driver_license_file
      t.datetime :board_certification_submitted
      t.string :board_certification_file
      t.string :status
      t.string :application_id
      t.string :not_submitted_note
      t.string :not_submitted_note_rejected
      t.datetime :approved_date
      t.string :approved_confirmation

      t.timestamps
    end
  end
end

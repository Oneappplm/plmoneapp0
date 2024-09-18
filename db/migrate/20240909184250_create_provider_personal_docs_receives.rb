class CreateProviderPersonalDocsReceives < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_docs_receives do |t|
      t.references :provider_attest
      t.integer    :caqh_provider_attest_id
      t.references :provider_personal_information, index: false
      t.integer    :caqh_provider_id

      # Received Dates
      t.date :application_received_date
      t.date :release_received_date
      t.date :disclosure_questions_explanation_received_date
      t.date :face_sheet_received_date
      t.date :employment_gap_received_date
      t.date :practice_information_received_date
      t.date :npdb_findings_explanation_received_date
      t.date :training_received_date
      t.date :education_received_date
      t.date :professional_resource_network_received_date
      t.date :dea_received_date
      t.date :pa_sponsor_request_form_received_date
      t.date :collaborative_agreement_received_date

      # Received Flags
      t.boolean :application_received_flag, default: false
      t.boolean :release_received_flag, default: false
      t.boolean :disclosure_questions_explanation_received_flag, default: false
      t.boolean :face_sheet_received_flag, default: false
      t.boolean :employment_gap_received_flag, default: false
      t.boolean :practice_information_received_flag, default: false
      t.boolean :npdb_findings_explanation_received_flag, default: false
      t.boolean :training_received_flag, default: false
      t.boolean :education_received_flag, default: false
      t.boolean :professional_resource_network_received_flag, default: false
      t.boolean :dea_received_flag, default: false
      t.boolean :pa_sponsor_request_form_received_flag, default: false
      t.boolean :collaborative_agreement_received_flag, default: false

      # Incomplete Flags
      t.boolean :application_received_incomplete_flag, default: false
      t.boolean :release_received_incomplete_flag, default: false
      t.boolean :disclosure_questions_explanation_received_incomplete_flag, default: false
      t.boolean :face_sheet_received_incomplete_flag, default: false
      t.boolean :employment_gap_received_incomplete_flag, default: false
      t.boolean :practice_information_received_incomplete_flag, default: false
      t.boolean :npdb_findings_explanation_received_incomplete_flag, default: false
      t.boolean :training_received_incomplete_flag, default: false
      t.boolean :education_received_incomplete_flag, default: false
      t.boolean :professional_resource_network_received_incomplete_flag, default: false
      t.boolean :dea_received_incomplete_flag, default: false
      t.boolean :pa_sponsor_request_form_received_incomplete_flag, default: false
      t.boolean :collaborative_agreement_received_incomplete_flag, default: false

      # Comments
      t.text :application_comments
      t.text :release_comments
      t.text :disclosure_questions_explanation_comments
      t.text :face_sheet_comments
      t.text :employment_gap_comments
      t.text :practice_information_comments
      t.text :npdb_findings_explanation_comments
      t.text :training_comments
      t.text :education_comments
      t.text :professional_resource_network_comments
      t.text :dea_comments
      t.text :pa_sponsor_request_form_comments
      t.text :collaborative_agreement_comments

      t.timestamps
    end

    add_index  :provider_personal_docs_receives, :provider_personal_information_id, :name => 'ppdr_ppi_id'
  end
end

class AddAttrToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :fax, :string
    add_column :providers, :provider_type, :string
    add_column :providers, :cred_cycle, :string
    add_column :providers, :encompass_id, :string
    add_column :providers, :provider_status, :string
    add_column :providers, :attested_date, :date
    add_column :providers, :file_due_date, :date
    add_column :providers, :application_complete_date, :date
    add_column :providers, :application_reviewed, :boolean
    add_column :providers, :batch_description, :text
    add_column :providers, :contact_method, :string
    add_column :providers, :attempt_status, :string
    add_column :providers, :contact_date, :date

    add_column :providers, :application_date, :date
    add_column :providers, :release_date, :date
    add_column :providers, :disclosure_questions_explanation_date, :date
    add_column :providers, :face_sheet_date, :date
    add_column :providers, :employment_gap_date, :date
    add_column :providers, :practice_information_date, :date
    add_column :providers, :npdb_findings_explanation_date, :date
    add_column :providers, :training_date, :date
    add_column :providers, :education_date, :date
    add_column :providers, :professional_resource_network_date, :date
    add_column :providers, :dea_date, :date
    add_column :providers, :pa_sponsor_request_form_date, :date
    add_column :providers, :collaborative_agreement_date, :date

    add_column :providers, :application_received_flag, :boolean, default: false
    add_column :providers, :release_received_flag, :boolean, default: false
    add_column :providers, :disclosure_questions_explanation_received_flag, :boolean, default: false
    add_column :providers, :face_sheet_received_flag, :boolean, default: false
    add_column :providers, :employment_gap_received_flag, :boolean, default: false
    add_column :providers, :practice_information_received_flag, :boolean, default: false
    add_column :providers, :npdb_findings_explanation_received_flag, :boolean, default: false
    add_column :providers, :training_received_flag, :boolean, default: false
    add_column :providers, :education_received_flag, :boolean, default: false
    add_column :providers, :professional_resource_network_received_flag, :boolean, default: false
    add_column :providers, :dea_received_flag, :boolean, default: false
    add_column :providers, :pa_sponsor_request_form_received_flag, :boolean, default: false
    add_column :providers, :collaborative_agreement_received_flag, :boolean, default: false

    add_column :providers, :application_received_incomplete_flag, :boolean, default: false
    add_column :providers, :release_received_incomplete_flag, :boolean, default: false
    add_column :providers, :disclosure_questions_explanation_received_incomplete_flag, :boolean, default: false
    add_column :providers, :face_sheet_received_incomplete_flag, :boolean, default: false
    add_column :providers, :employment_gap_received_incomplete_flag, :boolean, default: false
    add_column :providers, :practice_information_received_incomplete_flag, :boolean, default: false
    add_column :providers, :npdb_findings_explanation_received_incomplete_flag, :boolean, default: false
    add_column :providers, :training_received_incomplete_flag, :boolean, default: false
    add_column :providers, :education_received_incomplete_flag, :boolean, default: false
    add_column :providers, :professional_resource_network_received_incomplete_flag, :boolean, default: false
    add_column :providers, :dea_received_incomplete_flag, :boolean, default: false
    add_column :providers, :pa_sponsor_request_form_received_incomplete_flag, :boolean, default: false
    add_column :providers, :collaborative_agreement_received_incomplete_flag, :boolean, default: false

    add_column :providers, :application_comments, :text
    add_column :providers, :release_comments, :text
    add_column :providers, :disclosure_questions_explanation_comments, :text
    add_column :providers, :face_sheet_comments, :text
    add_column :providers, :employment_gap_comments, :text
    add_column :providers, :practice_information_comments, :text
    add_column :providers, :npdb_findings_explanation_comments, :text
    add_column :providers, :training_comments, :text
    add_column :providers, :education_comments, :text
    add_column :providers, :professional_resource_network_comments, :text
    add_column :providers, :dea_comments, :text
    add_column :providers, :pa_sponsor_request_form_comments, :text
    add_column :providers, :collaborative_agreement_comments, :text
  end
end

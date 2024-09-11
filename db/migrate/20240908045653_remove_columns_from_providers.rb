class RemoveColumnsFromProviders < ActiveRecord::Migration[7.0]
   def change
      remove_column :providers, :fax, :string
      remove_column :providers, :provider_type, :string
      remove_column :providers, :cred_cycle, :string
      remove_column :providers, :encompass_id, :string
      remove_column :providers, :provider_status, :string
      remove_column :providers, :attested_date, :date
      remove_column :providers, :file_due_date, :date
      remove_column :providers, :application_complete_date, :date
      remove_column :providers, :application_reviewed, :boolean
      remove_column :providers, :batch_description, :text
      remove_column :providers, :contact_method, :string
      remove_column :providers, :attempt_status, :string
      remove_column :providers, :contact_date, :date

      remove_column :providers, :application_date, :date
      remove_column :providers, :release_date, :date
      remove_column :providers, :disclosure_questions_explanation_date, :date
      remove_column :providers, :face_sheet_date, :date
      remove_column :providers, :employment_gap_date, :date
      remove_column :providers, :practice_information_date, :date
      remove_column :providers, :npdb_findings_explanation_date, :date
      remove_column :providers, :training_date, :date
      remove_column :providers, :education_date, :date
      remove_column :providers, :professional_resource_network_date, :date
      remove_column :providers, :dea_date, :date
      remove_column :providers, :pa_sponsor_request_form_date, :date
      remove_column :providers, :collaborative_agreement_date, :date

      remove_column :providers, :application_received_flag, :boolean
      remove_column :providers, :release_received_flag, :boolean
      remove_column :providers, :disclosure_questions_explanation_received_flag, :boolean
      remove_column :providers, :face_sheet_received_flag, :boolean
      remove_column :providers, :employment_gap_received_flag, :boolean
      remove_column :providers, :practice_information_received_flag, :boolean
      remove_column :providers, :npdb_findings_explanation_received_flag, :boolean
      remove_column :providers, :training_received_flag, :boolean
      remove_column :providers, :education_received_flag, :boolean
      remove_column :providers, :professional_resource_network_received_flag, :boolean
      remove_column :providers, :dea_received_flag, :boolean
      remove_column :providers, :pa_sponsor_request_form_received_flag, :boolean
      remove_column :providers, :collaborative_agreement_received_flag, :boolean

      remove_column :providers, :application_received_incomplete_flag, :boolean
      remove_column :providers, :release_received_incomplete_flag, :boolean
      remove_column :providers, :disclosure_questions_explanation_received_incomplete_flag, :boolean
      remove_column :providers, :face_sheet_received_incomplete_flag, :boolean
      remove_column :providers, :employment_gap_received_incomplete_flag, :boolean
      remove_column :providers, :practice_information_received_incomplete_flag, :boolean
      remove_column :providers, :npdb_findings_explanation_received_incomplete_flag, :boolean
      remove_column :providers, :training_received_incomplete_flag, :boolean
      remove_column :providers, :education_received_incomplete_flag, :boolean
      remove_column :providers, :professional_resource_network_received_incomplete_flag, :boolean
      remove_column :providers, :dea_received_incomplete_flag, :boolean
      remove_column :providers, :pa_sponsor_request_form_received_incomplete_flag, :boolean
      remove_column :providers, :collaborative_agreement_received_incomplete_flag, :boolean

      remove_column :providers, :application_comments, :text
      remove_column :providers, :release_comments, :text
      remove_column :providers, :disclosure_questions_explanation_comments, :text
      remove_column :providers, :face_sheet_comments, :text
      remove_column :providers, :employment_gap_comments, :text
      remove_column :providers, :practice_information_comments, :text
      remove_column :providers, :npdb_findings_explanation_comments, :text
      remove_column :providers, :training_comments, :text
      remove_column :providers, :education_comments, :text
      remove_column :providers, :professional_resource_network_comments, :text
      remove_column :providers, :dea_comments, :text
      remove_column :providers, :pa_sponsor_request_form_comments, :text
      remove_column :providers, :collaborative_agreement_comments, :text
    end
end

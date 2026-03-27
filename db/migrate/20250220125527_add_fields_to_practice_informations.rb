class AddFieldsToPracticeInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_informations, :provider_type, :string
    add_column :practice_informations, :cred_cycle, :string
    add_column :practice_informations, :birth_date, :date
    add_column :practice_informations, :ssn, :string
    add_column :practice_informations, :provider_status, :string
    add_column :practice_informations, :attestation_date, :date
    add_column :practice_informations, :file_due_date, :date
    add_column :practice_informations, :app_complete_date, :date
    add_column :practice_informations, :app_reviewed, :boolean
    add_column :practice_informations, :batch_description, :text
    add_column :practice_informations, :comment, :text
  end
end

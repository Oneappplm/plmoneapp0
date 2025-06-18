class AddMalpracticeClaimFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :mc_occurence_date, :date
    add_column :provider_personal_informations, :mc_date_claim_filed, :date
    add_column :provider_personal_informations, :mc_claim_status, :string
    add_column :provider_personal_informations, :mc_amount_award_settlement, :string
    add_column :provider_personal_informations, :mc_amount_award_attributed, :string
    add_column :provider_personal_informations, :mc_method_resolution, :string
    add_column :provider_personal_informations, :mc_date_settlement, :date
    add_column :provider_personal_informations, :mc_description_allegations, :text
    add_column :provider_personal_informations, :defendant_options, :string
    add_column :provider_personal_informations, :mc_defendant_number, :integer
    add_column :provider_personal_informations, :mc_case_involvement, :string
    add_column :provider_personal_informations, :mc_specific_responsibility, :text
    add_column :provider_personal_informations, :mc_description_alleged_patient, :text
    add_column :provider_personal_informations, :mc_patient_outcome, :text
    add_column :provider_personal_informations, :has_injury_to_death, :string
    add_column :provider_personal_informations, :has_npdb_case, :string
    add_column :provider_personal_informations, :has_malpractice_claim, :string
  end
end

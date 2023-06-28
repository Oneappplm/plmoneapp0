class AddQualifactsFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :practice_location_name, :string
    add_column :providers, :provider_effective_date, :date
    add_column :providers, :caqh_login, :string
    add_column :providers, :reattestation_date, :date
    add_column :providers, :security_question_answer, :string
    add_column :providers, :board_certified, :boolean
    add_column :providers, :birth_city_state, :string
    add_column :providers, :medical_school, :string
    add_column :providers, :medical_license, :string
    add_column :providers, :state_license, :string
    add_column :providers, :state_license_effective_date, :date
    add_column :providers, :state_license_expiration_date, :date
    add_column :providers, :pa_license_number, :string
    add_column :providers, :nccpa_expiration_date, :date
    add_column :providers, :ins_policy, :string
    add_column :providers, :ins_policy_effective_date, :date
    add_column :providers, :ins_policy_expiration_date, :date
    add_column :providers, :state_license_effectice_date, :date
  end
end

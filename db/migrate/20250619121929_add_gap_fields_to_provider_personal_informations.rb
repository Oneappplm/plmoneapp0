class AddGapFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :has_employment_gap, :string
    add_column :provider_personal_informations, :gap_start_date, :date
    add_column :provider_personal_informations, :gap_end_date, :date
    add_column :provider_personal_informations, :gap_until_present, :boolean
    add_column :provider_personal_informations, :gap_reason, :string
    add_column :provider_personal_informations, :gap_explanation, :text
  end
end

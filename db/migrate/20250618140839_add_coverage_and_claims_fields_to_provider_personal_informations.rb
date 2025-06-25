class AddCoverageAndClaimsFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :has_sovereign_immunity, :string
    add_column :provider_personal_informations, :has_liability_coverage, :string
    add_column :provider_personal_informations, :lf_lack_of_liability_coverage, :text
    add_column :provider_personal_informations, :is_self_insured, :string
  end
end
